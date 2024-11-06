import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class TeamFormat {
  final int minTeam;
  final int maxTeam;
  final int minPlayerPerTeam;
  final int maxPlayerPerTeam;

  const TeamFormat({
    required this.minTeam,
    required this.maxTeam,
    required this.minPlayerPerTeam,
    required this.maxPlayerPerTeam,
  });
}

class GameMasterWidget extends StatefulWidget {
  final HistoryGameMode gameMode;
  final List<List<Username>> teams;

  const GameMasterWidget({
    super.key,
    required this.gameMode,
    required this.teams,
  });

  @override
  State<GameMasterWidget> createState() => _GameMasterWidgetState();
}

class _GameMasterWidgetState extends State<GameMasterWidget> {
  List<Username> _requests = [];

  final _socketIoService = GetIt.I.get<SocketIoService>();

  bool get _canStartGame {
    TeamFormat teamFormat = _getTeamFormat();

    for (final team in widget.teams) {
      if (team.isEmpty) {
        continue;
      }
      if (team.length < teamFormat.minPlayerPerTeam ||
          teamFormat.maxPlayerPerTeam < team.length) {
        return false;
      }
    }

    final teamsLength = widget.teams.where((team) => team.isNotEmpty).length;
    return teamFormat.minTeam <= teamsLength &&
        teamsLength <= teamFormat.maxTeam;
  }

  @override
  void initState() {
    super.initState();
    _listenJoinRequests();
    _listenInvalidStartingState();
  }

  @override
  void dispose() {
    super.dispose();
    _socketIoService.off(GameManagerEvent.joinRequests);
    _socketIoService.off(GameManagerEvent.invalidStartingState);
  }

  List<Widget> get _buildSelectedPlayers {
    if (_requests.isEmpty) {
      return [];
    }

    final requests = _requests.map((username) {
      UserProfile userProfile =
          GetIt.I.get<UserService>().getUserByUsername(username);
      String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;

      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(username),
        trailing: Wrap(
          children: [
            IconButton(
              icon: const Icon(Icons.done, color: Colors.green),
              onPressed: () {
                _socketIoService.emit(
                  GameManagerEvent.approvePlayer,
                  UsernameDto(username: username).toJson(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () {
                _socketIoService.emit(
                  GameManagerEvent.rejectPlayer,
                  UsernameDto(username: username).toJson(),
                );
              },
            ),
          ],
        ),
      );
    }).toList();

    return [
      Text(
        AppLocalizations.of(context)!.playersToSelect,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      ...requests,
    ];
  }

  List<Widget> get _buildTeamFormat {
    final teamFormat = _getTeamFormat();
    final List<String> texts;

    if (widget.gameMode == HistoryGameMode.teamclassic) {
      final numberOfPlayersPerTeam =
          AppLocalizations.of(context)!.numberOfPlayersPerTeam;

      texts = [
        '$numberOfPlayersPerTeam: ${teamFormat.minPlayerPerTeam}',
        AppLocalizations.of(context)!.minTwoTeams
      ];
    } else {
      final numberOfPlayers = AppLocalizations.of(context)!.numberOfPlayers;
      final min = teamFormat.minPlayerPerTeam * teamFormat.minTeam;
      final max = teamFormat.maxPlayerPerTeam * teamFormat.maxTeam;

      texts = [
        '$numberOfPlayers: $min~$max',
      ];
    }

    return texts.map((t) => Text(t)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._buildSelectedPlayers,
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _canStartGame ? _endSelection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canStartGame ? Colors.green : null,
          ),
          child: Text(AppLocalizations.of(context)!.startGame),
        ),
        ..._buildTeamFormat,
      ],
    );
  }

  TeamFormat _getTeamFormat() {
    switch (widget.gameMode) {
      case HistoryGameMode.teamclassic:
        return const TeamFormat(
          minTeam: 2,
          maxTeam: 3,
          minPlayerPerTeam: 2,
          maxPlayerPerTeam: 2,
        );
      case HistoryGameMode.timelimitaugmented:
      case HistoryGameMode.timelimitsinglediff:
        return const TeamFormat(
          minTeam: 1,
          maxTeam: 1,
          minPlayerPerTeam: 2,
          maxPlayerPerTeam: 4,
        );
      case HistoryGameMode.classicmultiplayer:
        return const TeamFormat(
          minTeam: 2,
          maxTeam: 4,
          minPlayerPerTeam: 1,
          maxPlayerPerTeam: 1,
        );
      case HistoryGameMode.timelimitturnbyturn:
        return const TeamFormat(
          minTeam: 2,
          maxTeam: 2,
          minPlayerPerTeam: 1,
          maxPlayerPerTeam: 1,
        );
      default:
        throw 'Impossible game mode';
    }
  }

  void _endSelection() {
    _socketIoService.emit(GameManagerEvent.endSelection, null);
  }

  void _listenJoinRequests() {
    _socketIoService.onJoinRequests((joinRequestsDto) {
      setState(() {
        _requests = joinRequestsDto.requests;
      });
    });
  }

  void _listenInvalidStartingState() {
    _socketIoService.onInvalidStartingState(() {
      GetIt.I.get<LogService>().info('TODO invalid starting state');
    });
  }
}
