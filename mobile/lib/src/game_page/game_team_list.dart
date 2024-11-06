import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart' as swagger;
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/snackbar_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class PlayerData {
  final TeamIndex teamIndex;
  int differencesFoundCount;
  PlayerData(this.teamIndex, this.differencesFoundCount);
}

class GameTeamList extends StatefulWidget {
  final Map<TeamIndex, List<Username>> teams;
  final swagger.HistoryGameMode gameMode;
  final bool isObserver;
  final Map<Username, int>? playerScore;
  final Map<Username, PlayerData> playerData;

  const GameTeamList({
    super.key,
    required this.teams,
    required this.gameMode,
    required this.playerData,
    this.isObserver = false,
    this.playerScore = const {},
  }) : assert((playerScore != null) == isObserver);

  @override
  State<GameTeamList> createState() => _GameTeamListState();
}

class _GameTeamListState extends State<GameTeamList> {
  final Map<Username, PlayerData> playerData = {};
  TeamIndex _currentTurn = 0;

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();

  @override
  void initState() {
    super.initState();

    _listenOnPlayerLeave();
    _listenOnDifferencesFound();
    _listenOnChangeTemplate();
    _startGame();

    _socketIoService.onStartGame((startGameDto) {
      setState(() {
        for (final k in widget.playerData.keys) {
          widget.playerData[k]?.differencesFoundCount = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _socketIoService.off(GameManagerEvent.playerLeave);
    _socketIoService.off(GameManagerEvent.differenceFound);
    _socketIoService.off(GameManagerEvent.changeTemplate);
    _socketIoService.off(GameManagerEvent.startGame);
  }

  void _startGame() {
    widget.teams.forEach((teamIndex, teamMembers) {
      for (var username in teamMembers) {
        final score = widget.playerScore?[username] ?? 0;
        setState(() {
          widget.playerData[username] = PlayerData(teamIndex, score);
        });
      }
    });
  }

  Widget _buildTeamCard(TeamIndex teamIndex, List<Username> teamMembers) {
    Color? color;
    if (widget.gameMode == swagger.HistoryGameMode.timelimitturnbyturn &&
        _currentTurn == teamIndex) {
      color = Theme.of(context).primaryColor;
    }

    List<Widget> memberWidgets = teamMembers.map((username) {
      UserProfile userProfile =
          GetIt.I.get<UserService>().getUserByUsername(username);
      String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(username == GetIt.I.get<AuthController>().getUsername()
                ? '$username  (${AppLocalizations.of(context)!.you})'
                : username),
          ),
        ],
      );
    }).toList();

    int totalDifferences = teamMembers.fold(
      0,
      (previousValue, member) =>
          previousValue +
          (widget.playerData[member]?.differencesFoundCount ?? 0),
    );

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 10, // Spacing between each member
              runSpacing: 10, // Space between rows if wrap is needed
              children: memberWidgets,
            ),
            Text(
              '${AppLocalizations.of(context)!.differencesFound} $totalDifferences ★',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> teamEntries = widget.teams.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => _buildTeamCard(entry.key, entry.value))
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: teamEntries,
    );
  }

  void _listenOnPlayerLeave() {
    _socketIoService.on(GameManagerEvent.playerLeave, (data) {
      Username username = data['username'];
      setState(() {
        widget.playerData.remove(username);
        widget.teams.forEach((teamIndex, teamMembers) {
          widget.teams[teamIndex] =
              teamMembers.where((name) => name != username).toList();
        });
      });
      if (widget.isObserver) return;
      final player = AppLocalizations.of(context)!.player;
      final playerLeftGame = AppLocalizations.of(context)!.playerLeftGame;
      GetIt.I<SnackBarService>()
          .enqueueSnackBar('$player $username $playerLeftGame');
    });
  }

  void _listenOnDifferencesFound() {
    _socketIoService.onDifferenceFound((differenceFoundDto) {
      setState(() {
        widget.playerData[differenceFoundDto.username]?.differencesFoundCount++;
      });
    });
  }

  void _listenOnChangeTemplate() {
    _socketIoService.onChangeTemplate((changeTemplateDto) {
      setState(() {
        _currentTurn = (_currentTurn + 1) % widget.teams.length;
      });
    });
  }
}
