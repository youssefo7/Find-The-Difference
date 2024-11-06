import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/generated/api.enums.swagger.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/selection_page/game_config_dialog.dart';
import 'package:mobile/src/selection_page/selection_page_view.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  Widget _buildButton(HistoryGameMode gameMode) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FilledButton(
        onPressed: () {
          _onPressed(gameMode);
        },
        child: Text(gameModeToString(context, gameMode)),
      ),
    );
  }

  List<Widget> get _buildRadio {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppLocalizations.of(context)!.classicModes,
          textAlign: TextAlign.left,
        ),
      ),
      _buildButton(HistoryGameMode.classicmultiplayer),
      _buildButton(HistoryGameMode.teamclassic),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppLocalizations.of(context)!.limitedTimeModes,
          textAlign: TextAlign.left,
        ),
      ),
      _buildButton(HistoryGameMode.timelimitaugmented),
      _buildButton(HistoryGameMode.timelimitsinglediff),
      _buildButton(HistoryGameMode.timelimitturnbyturn),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectGameMode),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildRadio,
        ),
      ),
    );
  }

  void _onPressed(HistoryGameMode gameMode) {
    Navigator.of(context).pop();

    if (isTimeLimit(gameMode)) {
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return GameConfigDialog(
              gameTemplate: null,
              gameMode: gameMode,
            );
          });
      return;
    }

    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => SelectionPageView(
            pageType: PageType.createGame, gameMode: gameMode),
      ),
    );
  }
}
