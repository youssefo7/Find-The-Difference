import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/replay/recording_service.dart';
import 'package:mobile/src/replay/replay_view.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';

const highScoreMoney = 25;

class EndGameDialog extends StatelessWidget {
  final EndGameDto endGameDto;
  final HistoryGameMode gameMode;
  final GameTemplate? gameTemplate;
  final bool isObserver;

  EndGameDialog({
    super.key,
    required this.endGameDto,
    required this.gameMode,
    required this.gameTemplate,
    this.isObserver = false,
  }) {
    assert(!isTimeLimit(gameMode) == (gameTemplate != null));
  }

  List<Widget> _buildWinLossTexts(BuildContext context) {
    if (isObserver) {
      return [Text(AppLocalizations.of(context)!.thanksForWatching)];
    }

    final winner = AppLocalizations.of(context)!.winner;
    final loser = AppLocalizations.of(context)!.loser;
    final time = AppLocalizations.of(context)!.time;
    final seconds = AppLocalizations.of(context)!.seconds;
    final youWin = AppLocalizations.of(context)!.youWin;
    final youLost = AppLocalizations.of(context)!.youLost;

    final money =
        AppLocalizations.of(context)!.money(endGameDto.pointsReceived);
    final newHighScore = AppLocalizations.of(context)!.newHighScore;
    final List<Text> winLossText = [];
    final username = GetIt.I.get<AuthController>().getUsername();

    switch (gameMode) {
      case HistoryGameMode.classicmultiplayer:
      case HistoryGameMode.teamclassic:
        winLossText.add(Text('$winner: ${endGameDto.winners.join(", ")}'));
        winLossText.add(Text('$loser: ${endGameDto.losers.join(", ")}'));
        winLossText
            .add(Text('$time: ${endGameDto.totalTimeMs ~/ 1000} $seconds'));
      case HistoryGameMode.timelimitturnbyturn:
      case HistoryGameMode.timelimitsinglediff:
      case HistoryGameMode.timelimitaugmented:
        winLossText.add(Text(AppLocalizations.of(context)!.thanksForPlaying));
      case HistoryGameMode.swaggerGeneratedUnknown:
        throw 'impossible';
    }

    winLossText
        .add(Text(endGameDto.winners.contains(username) ? youWin : youLost));
    winLossText.add(Text(money));
    if (endGameDto.pointsReceived == highScoreMoney) {
      winLossText.add(Text(newHighScore));
    }
    return winLossText;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.gameOver),
      content: SingleChildScrollView(
        child: ListBody(
          children: _buildWinLossTexts(context),
        ),
      ),
      actions: [
        if (!isTimeLimit(gameMode) && !isObserver)
          TextButton(
            child: Text(AppLocalizations.of(context)!.replay),
            onPressed: () => _openReplayView(context),
          ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.close),
          onPressed: () {
            Navigator.of(context).pop();
            navigatorKey.currentState!.popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  void _openReplayView(BuildContext context) async {
    ReceiveReplayDto replayDto = ReceiveReplayDto(
      id: '',
      events: GetIt.I.get<RecordingService>().events,
      gameTemplateId: gameTemplate!.id,
      gameMode: receiveReplayDtoGameModeFromString(gameMode.value),
      username: GetIt.I.get<AuthController>().getUsername(),
    );

    Navigator.of(context).pop();
    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    // this off prevents the listener WaitingLobby to be triggered,
    // or else the fake startGame event emitted from the replay will try to open a new GamePage
    GetIt.I.get<SocketIoService>().off(GameManagerEvent.startGame);

    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => ReplayView(
          replayDto: replayDto,
          gameTemplate: gameTemplate!,
          isSaveButtonHidden: false,
        ),
      ),
    );
  }
}
