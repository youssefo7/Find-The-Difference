import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/app_bar_widget.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/chat/chat_model.dart';
import 'package:mobile/src/game_page/end_game_dialog.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/game_page/game_team_list.dart';
import 'package:mobile/src/game_page/game_timer.dart';
import 'package:mobile/src/game_page/hint_info.dart';
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/game_page/observer_list.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/game_template.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/replay/replay_service.dart';
import 'package:mobile/src/selection_page/time_config_constants.dart';
import 'package:mobile/src/services/balance_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';
import 'package:mobile/src/userProfile/statistics_tab/statistics_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class GamePageView extends StatelessWidget {
  final StartGameDto? startGameDto;
  final GameTemplate? gameTemplate;
  final HistoryGameMode gameMode;
  final bool isObserver;
  final ObserverGameDto? observerGameDto;

  const GamePageView({
    super.key,
    this.startGameDto,
    required this.gameTemplate,
    required this.gameMode,
    this.isObserver = false,
    this.observerGameDto,
  })  : assert(!isObserver == (startGameDto != null)),
        assert((isObserver) == (observerGameDto != null));

  @override
  Widget build(BuildContext context) {
    final name = gameTemplate?.name.toUpperCase();
    final gameModeString = gameModeToString(context, gameMode);
    final pageTitle = name == null ? gameModeString : '$name - $gameModeString';

    return Scaffold(
      appBar: AppBarWidget(pageTitle: pageTitle, isGamePage: true),
      body: GamePageBody(
        startGameDto: startGameDto,
        gameTemplate: gameTemplate,
        gameMode: gameMode,
        isObserver: isObserver,
        observerGameDto: observerGameDto,
      ),
    );
  }
}

class GamePageBody extends StatefulWidget {
  final StartGameDto? startGameDto;
  final GameTemplate? gameTemplate;
  final HistoryGameMode gameMode;
  final bool isObserver;
  final ObserverGameDto? observerGameDto;

  const GamePageBody({
    super.key,
    required this.startGameDto,
    required this.gameTemplate,
    required this.gameMode,
    required this.isObserver,
    required this.observerGameDto,
  });

  @override
  State<GamePageBody> createState() => _GamePageState();
}

class _GamePageState extends State<GamePageBody> {
  StartGameDto? startGameDto;
  ShowErrorDto? _errorLocation;
  bool isLoading = true;
  final Map<Username, PlayerData> _playerData = {};

  final List<HintInfo> _hints = [];

  double get _width =>
      min(imageWidth.toDouble(), MediaQuery.of(context).size.width * 0.45);
  double get _ratio => _width / imageWidth;

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();
  ImageController get _imageController => GetIt.I.get<ImageController>();
  BalanceService get _balanceService => GetIt.I<BalanceService>();

  final List<Username> _observers = [];
  Map<Username, int>? _playerScore;
  late List<Username> _players;

  bool _buyDisabled = false;

  Rect? _drawnRect;
  Offset? _firstClick;
  Username? _hintTarget;
  bool _observerOnCooldown = false;

  @override
  void initState() {
    super.initState();
    startGameDto = widget.startGameDto;
    if (widget.isObserver) {
      _hintTarget = everyone;
      _listenOnObserverStateSync();
      _players = widget.observerGameDto!.players;
      _listenOnPlayerLeave();
    } else {
      isLoading = false;
    }
    _listenOnReceiveHint();
    _socketIoService.on(GameManagerEvent.showError, _onShowError);
    _listenOnEndGame();
  }

  @override
  void dispose() {
    super.dispose();
    _socketIoService.emit(GameManagerEvent.leaveGame, null);
    _socketIoService.off(GameManagerEvent.showError, _onShowError);
    _socketIoService.off(GameManagerEvent.endGame);
    _socketIoService.off(GameManagerEvent.observerStateSync);
    _socketIoService.off(GameManagerEvent.playerLeave);
    _socketIoService.off(GameManagerEvent.receiveHint);
  }

  Widget _buildClickableImage(ImageClicked side) {
    final image = _imageController.getImage(side);

    if (image == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _width,
      child: GestureDetector(
        onTapDown: (details) {
          if (!widget.isObserver) {
            final p = details.localPosition * (imageWidth.toDouble()) / _width;
            final position = Vec2(x: p.dx.round(), y: p.dy.round());
            _socketIoService.emit(
              GameManagerEvent.identifyDifference,
              IdentifyDifferenceDto(position: position, imageClicked: side),
            );
          }
        },
        onPanStart: (details) {
          if (!widget.isObserver || _observerOnCooldown) return;
          setState(() {
            _firstClick = details.localPosition;
            _drawnRect = Rect.fromLTWH(
                details.localPosition.dx, details.localPosition.dy, 0.1, 0.1);
          });
        },
        onPanUpdate: (details) {
          if (!widget.isObserver || _observerOnCooldown) return;
          setState(() {
            _drawnRect = Rect.fromPoints(_firstClick!, details.localPosition);
          });
        },
        onPanEnd: (details) {
          if (!widget.isObserver || _observerOnCooldown) {
            return;
          }
          if (_drawnRect != null) {
            giveHint();
          }
        },
        child: Stack(
          children: [
            image,
            if (_errorLocation != null && _errorLocation!.imageClicked == side)
              Positioned(
                left: _errorLocation!.position.x.toDouble(),
                top: _errorLocation!.position.y.toDouble(),
                child: Text(
                  AppLocalizations.of(context)!.error.toUpperCase(),
                  style: const TextStyle(color: Colors.red, fontSize: 24),
                ),
              ),
            if (_hints.isNotEmpty)
              ..._hints.map((hint) {
                return Positioned(
                  left: hint.rect.left.toDouble(),
                  top: hint.rect.top.toDouble(),
                  width: hint.rect.width.toDouble(),
                  height: hint.rect.height.toDouble(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: hint.sender != serverUsername
                              ? Colors.green
                              : Colors.blue,
                          width: 2.0),
                    ),
                    child: Text(
                      hint.sender != serverUsername ? hint.sender : '',
                      style: TextStyle(
                        color: hint.sender != serverUsername
                            ? Colors.green
                            : Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }),
            if (widget.isObserver && _drawnRect != null)
              Positioned.fromRect(
                rect: _drawnRect!,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget get _buildBottomButtons {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (startGameDto!.timeConfig.cheatModeAllowed && !widget.isObserver)
          ElevatedButton(
            onPressed: () {
              GetIt.I.get<ImageController>().toggleCheatMode();
            },
            child: Text(
              AppLocalizations.of(context)!.cheatMode,
            ),
          ),
        if (!widget.isObserver)
          ListenableBuilder(
              listenable: _balanceService,
              builder: (context, child) => ElevatedButton(
                    onPressed:
                        _buyDisabled || _balanceService.balance < hintPrice
                            ? null
                            : () {
                                buyHint();
                              },
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money),
                        Text(
                            ' ${hintPrice.toString()}  ${AppLocalizations.of(context)!.hint}'),
                      ],
                    ),
                  )),
        if (widget.isObserver) _buildObserverInteractionCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                const GameTimer(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GameObservers(observers: _observers),
                    ],
                  ),
                ),
              ],
            ),
            GameTeamList(
              playerData: _playerData,
              teams: startGameDto!.teams,
              gameMode: widget.gameMode,
              isObserver: widget.isObserver,
              playerScore: widget.isObserver ? _playerScore : null,
            ),
            ListenableBuilder(
              listenable: _imageController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildClickableImage(ImageClicked.left),
                    _buildClickableImage(ImageClicked.right)
                  ],
                );
              },
            ),
            if (!GetIt.I.get<ReplayService>().isInReplayMode)
              _buildBottomButtons,
          ],
        ));
  }

  void _onShowError(dynamic dto) {
    ShowErrorDto showErrorDto = ShowErrorDto.fromJson(dto);
    final x = showErrorDto.position.x.toDouble();
    final y = showErrorDto.position.y.toDouble();
    final p = Vec2(
      x: (x * _ratio).round(),
      y: (y * _ratio).round(),
    );

    setState(() {
      _errorLocation =
          ShowErrorDto(position: p, imageClicked: showErrorDto.imageClicked);
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _errorLocation = null;
        });
      }
    });
  }

  void _listenOnEndGame() {
    _socketIoService.onEndGame((endGameDto) {
      final playerData =
          _playerData[GetIt.I.get<AuthController>().getUsername()];
      if (playerData != null && widget.gameTemplate != null) {
        final differencesFoundCount = playerData.differencesFoundCount;
        final nGroups = widget.startGameDto!.nGroups;
        GetIt.I
            .get<StatisticsService>()
            .patchStatistics(differencesFoundCount / nGroups);
      }

      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EndGameDialog(
              endGameDto: endGameDto,
              gameTemplate:
                  isTimeLimit(widget.gameMode) ? null : widget.gameTemplate,
              gameMode: widget.gameMode,
              isObserver: widget.isObserver,
            );
          });
    });
  }

  void _listenOnObserverStateSync() {
    _imageController.precacheGameTemplate(context, widget.gameTemplate!);

    _socketIoService.onObserverStateSync((stateDto) {
      for (var observer in stateDto.observers) {
        _observers.add(observer);
      }
      setState(() {
        startGameDto = stateDto.startGameDto;
        _playerScore = stateDto.playerScore;
        isLoading = false;
      });
      if (stateDto.timeLimitPreload != null) {
        _imageController.onChangeTemplate(stateDto.timeLimitPreload![0]);
        _imageController.onChangeTemplate(stateDto.timeLimitPreload![1]);
      } else {
        _imageController.updateGameState(stateDto.pixelToRemove);
      }
    });

    GetIt.I.get<SocketIoService>().emit(
          GameManagerEvent.joinGameObserver,
          JoinGameDto(instanceId: widget.observerGameDto!.instanceId).toJson(),
        );
  }

  Widget _buildObserverInteractionCard() {
    return Card(
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!.sendHintTo,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: everyone,
                      groupValue: _hintTarget,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _hintTarget = value;
                          });
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_hintTarget != everyone) {
                          setState(() {
                            _hintTarget = everyone;
                          });
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.everyone),
                    ),
                  ],
                ),
                ..._players.map((player) {
                  UserProfile userProfile =
                      GetIt.I.get<UserService>().getUserByUsername(player);
                  String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Radio<String>(
                      value: player,
                      groupValue: _hintTarget,
                      onChanged: (String? value) {
                        setState(() {
                          _hintTarget = value!;
                        });
                      },
                    ),
                    GestureDetector(
                        onTap: () {
                          if (_hintTarget != player) {
                            setState(() {
                              _hintTarget = player;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  avatarUrl), // Display the player's avatar
                              radius: 16, // Set the radius of the avatar
                            ),
                            const SizedBox(width: 10),
                            Text(player),
                          ],
                        )),
                  ]);
                }),
              ]),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  void _listenOnPlayerLeave() {
    _socketIoService.on(GameManagerEvent.playerLeave, (data) {
      Username username = data['username'];
      _players.remove(username);
    });
  }

  void _listenOnReceiveHint() {
    _socketIoService.onReceiveHint((hintDto) {
      if (widget.isObserver &&
          hintDto.sender != GetIt.I.get<AuthController>().getUsername()) {
        return;
      }
      drawHint(hintDto);
      Timer(const Duration(seconds: hintCooldown), () {
        setState(() {
          _hints.removeAt(0);
        });
      });
    });
  }

  void drawHint(ReceiveHintDto hintDto) {
    setState(() {
      _hints.add(HintInfo(
        sender: hintDto.sender,
        rect: Rect.fromLTWH(
          hintDto.rect[0].x.toDouble() * _ratio,
          hintDto.rect[0].y.toDouble() * _ratio,
          hintDto.rect[1].x.toDouble() * _ratio,
          hintDto.rect[1].y.toDouble() * _ratio,
        ),
      ));
    });
  }

  void giveHint() {
    double height = (_drawnRect!.bottom - _drawnRect!.top);
    double width = (_drawnRect!.right - _drawnRect!.left);

    if ((width).abs() < 5 || (height).abs() < 5) {
      setState(() {
        _drawnRect = null;
      });
      return;
    }

    double x = (_drawnRect!.left / _ratio).roundToDouble();
    double y = (_drawnRect!.top / _ratio).roundToDouble();
    double rectWidth = (width / _ratio).roundToDouble();
    double rectHeight = (height / _ratio).roundToDouble();

    x = x.clamp(0, imageWidth - 1.0);
    y = y.clamp(0, imageHeight - 1.0);
    rectWidth = rectWidth.clamp(0, imageWidth - 1.0 - x);
    rectHeight = rectHeight.clamp(0, imageHeight - 1.0 - y);

    SendHintDto sendHintDto = SendHintDto(
      rect: [
        Vec2(x: x.toInt(), y: y.toInt()),
        Vec2(x: rectWidth.toInt(), y: rectHeight.toInt()),
      ],
      player: _hintTarget == everyone ? null : _hintTarget,
    );
    _socketIoService.emit(GameManagerEvent.sendHint, sendHintDto);
    setState(() {
      _drawnRect = null;
      _observerOnCooldown = true;
    });
    Timer(const Duration(seconds: hintCooldown), () {
      setState(() {
        _observerOnCooldown = false;
      });
    });
  }

  void buyHint() {
    _socketIoService.emit(GameManagerEvent.hint, null);
    _buyDisabled = true;
    Timer(const Duration(seconds: hintCooldown), () {
      setState(() {
        _buyDisabled = false;
      });
    });
  }
}
