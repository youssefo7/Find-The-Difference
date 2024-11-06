import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/generated/api.swagger.dart' as swagger;
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';
import 'package:mobile/src/userProfile/history_tab/game_history_service.dart';

class GameHistoryWidget extends StatefulWidget {
  const GameHistoryWidget({super.key});

  @override
  State<GameHistoryWidget> createState() => _GameHistoryWidgetState();
}

class _GameHistoryWidgetState extends State<GameHistoryWidget> {
  late Future<List<swagger.History>> gameHistoryFuture;
  final GameHistoryService gameHistoryService = GetIt.I<GameHistoryService>();

  @override
  void initState() {
    super.initState();
    final username = GetIt.I.get<AuthController>().getUsername();
    gameHistoryFuture = gameHistoryService.fetchGameHistory(username);
  }

  String determineStatus(swagger.History history, String username) {
    if (history.winners.contains(username)) {
      return AppLocalizations.of(context)!.winner;
    } else if (history.losers.contains(username)) {
      return AppLocalizations.of(context)!.loser;
    } else if (history.quitters.contains(username)) {
      return AppLocalizations.of(context)!.quitter;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<swagger.History>>(
      future: gameHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.errorFetchingData));
        } else {
          final historyList = snapshot.data!;
          if (historyList.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noGameHistory));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.gameHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final historyItem = historyList[index];
                    final status = determineStatus(historyItem,
                        GetIt.I.get<AuthController>().getUsername());
                    final start = DateFormat('yyyy-MM-dd – h:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          historyItem.startTime.toInt()),
                    );

                    return ListTile(
                      title:
                          Text(gameModeToString(context, historyItem.gameMode)),
                      subtitle: Text('$status - $start'),
                    );
                  },
                ),
              )
            ],
          );
        }
      },
    );
  }
}
