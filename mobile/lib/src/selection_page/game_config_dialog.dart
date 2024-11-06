import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/selection_page/time_config_constants.dart'
    as constants;
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';
import 'package:mobile/src/waiting_lobby/waiting_lobby_view.dart';

class GameConfigDialog extends StatefulWidget {
  final GameTemplate? gameTemplate;
  final HistoryGameMode gameMode;

  GameConfigDialog({
    super.key,
    required this.gameTemplate,
    required this.gameMode,
  }) {
    assert(isTimeLimit(gameMode) == (gameTemplate == null));
  }

  @override
  State<GameConfigDialog> createState() => _GameConfigDialogState();
}

class _GameConfigDialogState extends State<GameConfigDialog> {
  int _totalTime = constants.defaultTotalTime;
  int _rewardTime = constants.defaultRewardTime;
  bool _isCheatModeAllowed = false;

  Widget get _buildTotalTimeSlider {
    final initialTime = AppLocalizations.of(context)!.initialTime;

    return ListTile(
      title: Text('$initialTime: $_totalTime'),
      subtitle: Row(
        children: [
          Text(constants.minGameTime.toString()),
          Slider(
            value: _totalTime.toDouble(),
            min: constants.minGameTime.toDouble(),
            max: constants.maxGameTime.toDouble(),
            onChanged: (value) {
              setState(() {
                _totalTime = value.round();
              });
            },
          ),
          Text(constants.maxGameTime.toString()),
        ],
      ),
    );
  }

  Widget get _buildRewardTimeSlider {
    final rewardTime = AppLocalizations.of(context)!.rewardTime;

    return ListTile(
      title: Text('$rewardTime: $_rewardTime'),
      subtitle: Row(
        children: [
          Text(constants.minTimeJump.toString()),
          Slider(
            value: _rewardTime.toDouble(),
            min: constants.minTimeJump.toDouble(),
            max: constants.maxTimeJump.toDouble(),
            onChanged: (value) {
              setState(() {
                _rewardTime = value.round();
              });
            },
          ),
          Text(constants.maxTimeJump.toString()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.configuration),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            _buildTotalTimeSlider,
            if (widget.gameMode != HistoryGameMode.timelimitturnbyturn)
              _buildRewardTimeSlider,
            CheckboxListTile(
              title: Text(AppLocalizations.of(context)!.cheatMode),
              value: _isCheatModeAllowed,
              onChanged: (value) {
                setState(() {
                  _isCheatModeAllowed = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _createLobby,
          child: Text(AppLocalizations.of(context)!.createLobby),
        ),
      ],
    );
  }

  void _createLobby() {
    final timeConfigDto = TimeConfigDto(
      totalTime: _totalTime,
      rewardTime: _rewardTime,
      cheatModeAllowed: _isCheatModeAllowed,
    );
    final gameTemplateId =
        isTimeLimit(widget.gameMode) ? '' : widget.gameTemplate!.id;

    final dto = InstantiateGameDto(
      gameTemplateId: gameTemplateId,
      gameMode: widget.gameMode,
      timeConfig: timeConfigDto,
    );

    GetIt.I.get<SocketIoService>().emit(
          GameManagerEvent.instantiateGame,
          dto.toJson(),
        );

    Navigator.of(context).pop();
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => WaitingLobbyView(
          gameTemplate: widget.gameTemplate,
          gameMode: widget.gameMode,
        ),
      ),
    );
  }
}
