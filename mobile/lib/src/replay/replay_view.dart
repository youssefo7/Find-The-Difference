import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/app_bar_widget.dart';
import 'package:mobile/src/game_page/game_page_view.dart';
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/replay/replay_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';

class ReplayView extends StatefulWidget {
  final ReceiveReplayDto replayDto;
  final GameTemplate gameTemplate;
  final bool isSaveButtonHidden;

  const ReplayView({
    super.key,
    required this.replayDto,
    required this.gameTemplate,
    required this.isSaveButtonHidden,
  });

  @override
  State<ReplayView> createState() => _ReplayController();
}

class _ReplayController extends State<ReplayView> {
  int currentReplaySpeed = possibleReplaySpeeds[0];

  ReplayService get _replayService => GetIt.I.get<ReplayService>();
  ImageController get _imageController => GetIt.I.get<ImageController>();

  @override
  void initState() {
    super.initState();
    _replayService.loadReplay(widget.replayDto);

    _imageController.precacheGameTemplate(context, widget.gameTemplate);
  }

  @override
  void dispose() {
    super.dispose();
    _replayService.uninitialize();
  }

  @override
  Widget build(BuildContext context) => _ReplayView(state: this);

  void restartPlayback() {
    _replayService.setFraction(0);
    _replayService.recalculateFromKeyFrame();
    _imageController.precacheGameTemplate(
      context,
      widget.gameTemplate,
    );
  }

  void onPausePlayClick() {
    if (_replayService.isAtEndOfReplay()) {
      restartPlayback();
    }
    _replayService.togglePlayback();
  }

  void changeSpeed() {
    var index = possibleReplaySpeeds.indexOf(_replayService.currentReplaySpeed);
    index = (index + 1) % possibleReplaySpeeds.length;
    _replayService.currentReplaySpeed = possibleReplaySpeeds[index];
    setState(() {});
  }
}

class _ReplayView extends StatefulWidget {
  final _ReplayController state;
  const _ReplayView({required this.state});

  @override
  State<_ReplayView> createState() => _ReplayViewState();
}

class _ReplayViewState extends State<_ReplayView> {
  ReplayService get _replayService => GetIt.I.get<ReplayService>();

  bool _isControlMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    final startGameDto = StartGameDto.fromJson(
      widget.state.widget.replayDto.events.first.data as Map<String, dynamic>,
    );
    final gameMode =
        historyGameModeFromString(widget.state.widget.replayDto.gameMode.value);

    return Scaffold(
      appBar: const AppBarWidget(pageTitle: 'Replay', isGamePage: false),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isControlMenuVisible =
                    !_isControlMenuVisible; // Toggle visibility
              });
            },
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.red,
                  width: 16,
                )),
                child: GamePageBody(
                  startGameDto: startGameDto,
                  gameTemplate: widget.state.widget.gameTemplate,
                  gameMode: gameMode,
                  isObserver: false,
                  observerGameDto: null,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _isControlMenuVisible ? 1 : 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isControlMenuVisible
                    ? null
                    : () {
                        setState(() {
                          _isControlMenuVisible =
                              !_isControlMenuVisible; // Toggle visibility
                        });
                      },
                child: _buildControlMenu,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _buildControlMenu {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
            listenable: _replayService,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Slider(
                      value: min(1, _replayService.currentFraction),
                      max: 1,
                      onChanged: (double value) {
                        _replayService.setFraction(value);
                      },
                      onChangeEnd: (double value) {
                        _replayService.setFraction(value);
                        _replayService.recalculateFromKeyFrame();
                        widget.state._imageController.precacheGameTemplate(
                          context,
                          widget.state.widget.gameTemplate,
                        );
                      },
                    ),
                  ),
                  _buildButtons,
                ],
              );
            }),
      ),
    );
  }

  Widget get _buildButtons {
    final speedButtonText = '${_replayService.currentReplaySpeed}x';

    return Wrap(
      spacing: 8.0,
      children: [
        IconButton.filled(
          onPressed: () => widget.state.restartPlayback(),
          icon: const Icon(Icons.fast_rewind),
        ),
        IconButton.filled(
          onPressed: widget.state.onPausePlayClick,
          icon: Icon(
            _replayService.isReplaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        TextButton(
          onPressed: widget.state.changeSpeed,
          child: Text(speedButtonText),
        ),
        IconButton.filled(
          onPressed: _goToHome,
          icon: const Icon(Icons.home),
        ),
        if (!widget.state.widget.isSaveButtonHidden)
          IconButton.filled(
            onPressed: _uploadReplay,
            icon: const Icon(Icons.save),
          ),
      ],
    );
  }

  void _goToHome() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> _uploadReplay() async {
    _goToHome();

    final replayDto = SendReplayDto(
      events: widget.state.widget.replayDto.events,
      gameTemplateId: widget.state.widget.replayDto.gameTemplateId,
      gameMode: sendReplayDtoGameModeFromString(
          widget.state.widget.replayDto.gameMode.value),
    );

    await GetIt.I.get<Api>().apiUserAddReplayPost(
          body: replayDto,
        );
  }
}
