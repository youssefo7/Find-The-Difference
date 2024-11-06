import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/game_page/game_page_view.dart';
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/replay/recording_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';
import 'package:mobile/src/waiting_lobby/game_master_widget.dart';

class WaitingLobbyView extends StatefulWidget {
  final GameTemplate? gameTemplate;
  final HistoryGameMode gameMode;

  const WaitingLobbyView({
    super.key,
    required this.gameTemplate,
    required this.gameMode,
  });

  @override
  State<WaitingLobbyView> createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobbyView> {
  TeamIndex _currentTeam = 0;
  List<Username> _players = [];
  List<List<Username>> _teams = [];
  bool _isGameMaster = false;

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();
  ImageController get _imageController => GetIt.I.get<ImageController>();

  @override
  void initState() {
    super.initState();
    _listenOnStartGame();
    _listenJoinRequests();
    _listenAssignGameMaster();
    _listenWaitingRefusal();
    _listenOnInstanceDeletion();

    GetIt.I.get<ImageController>().initialize();
    GetIt.I.get<RecordingService>().initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.gameTemplate != null) {
      _imageController.reset();
      _imageController.precacheGameTemplate(context, widget.gameTemplate!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _socketIoService.emit(GameManagerEvent.leaveGame, null);
    _socketIoService.off(GameManagerEvent.startGame);
    _socketIoService.off(GameManagerEvent.joinRequests);
    _socketIoService.off(GameManagerEvent.waitingRefusal);
    _socketIoService.off(GameManagerEvent.assignGameMaster);
    _socketIoService.off(GameManagerEvent.onInstanceDeletion);

    GetIt.I.get<ImageController>().uninitialize();
  }

  Widget get _buildTeams {
    final teamText = AppLocalizations.of(context)!.team;

    final teams = _teams.indexed.map((t) {
      final (i, team) = t;

      List<Widget> teamMembersWidgets = team.map((username) {
        UserProfile userProfile =
            GetIt.I.get<UserService>().getUserByUsername(username);
        String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 16, // Customize this value as needed
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(username),
            ),
          ],
        );
      }).toList();

      onTap([int? value]) {
        _socketIoService.emit(
          GameManagerEvent.changeTeam,
          ChangeTeamDto(newTeam: i).toJson(),
        );
      }

      return Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            title: Text('$teamText ${i + 1}'),
            subtitle: Wrap(
              spacing: 8, // Space between each team member entry
              children: teamMembersWidgets,
            ),
            leading: Radio<int>(
              value: i,
              groupValue: _currentTeam,
              onChanged: onTap,
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.teamSelection,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...teams,
      ],
    );
  }

  Widget get _buildAcceptedPlayers {
    final colorScheme = material.Theme.of(context).colorScheme;
    final players = _players.map((player) {
      UserProfile userProfile =
          GetIt.I.get<UserService>().getUserByUsername(player);
      String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;

      return Card(
        color: colorScheme.primary,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          title: Text(
            player,
            style: TextStyle(color: colorScheme.onPrimary),
          ),
        ),
      );
    }).toList();

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.acceptedPlayers,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...players,
      ],
    );
  }

  Widget get _buildLeftColumn {
    return Column(
      children: [
        if (widget.gameMode == HistoryGameMode.teamclassic) _buildTeams,
        if (widget.gameMode != HistoryGameMode.teamclassic)
          _buildAcceptedPlayers,
        if (_isGameMaster)
          GameMasterWidget(gameMode: widget.gameMode, teams: _teams)
      ],
    );
  }

  Widget get _buildBody {
    String username = GetIt.I.get<AuthController>().getUsername();
    bool isInTheLobby = _players.contains(username);

    if (!isInTheLobby) {
      return Center(
        child: Text(AppLocalizations.of(context)!.waitingGameMaster),
      );
    }
    return Row(
      children: [
        const Spacer(),
        Expanded(child: _buildLeftColumn),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.waitingLobby)),
      body: _buildBody,
    );
  }

  void _listenOnStartGame() {
    _socketIoService
        .onStartGame((startGameDto) => navigatorKey.currentState!.push(
              MaterialPageRoute(
                  builder: (context) => GamePageView(
                        startGameDto: startGameDto,
                        gameTemplate: widget.gameTemplate,
                        gameMode: widget.gameMode,
                      )),
            ));
  }

  void _listenJoinRequests() {
    _socketIoService.onJoinRequests((joinRequestsDto) {
      setState(() {
        _players = joinRequestsDto.players;
        _teams = joinRequestsDto.teams;

        _currentTeam = _teams.indexWhere(
          (team) => team.contains(GetIt.I.get<AuthController>().getUsername()),
        );
      });
    });
  }

  void _listenWaitingRefusal() {
    _socketIoService.onWaitingRefusal(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.waitingRefusal),
      ));
      navigatorKey.currentState!.pop(context);
    });
  }

  void _listenAssignGameMaster() {
    _socketIoService.onAssignGameMaster(() {
      setState(() {
        _isGameMaster = true;
      });
    });
  }

  void _listenOnInstanceDeletion() {
    _socketIoService.onInstanceDeletion(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.instanceDeletion),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.close),
                onPressed: () {
                  Navigator.of(context).pop();
                  navigatorKey.currentState!.popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
    });
  }
}
