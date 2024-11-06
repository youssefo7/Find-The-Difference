import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/generated/api.swagger.dart' as swagger;
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/replay/replay_view.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';

class ReplayHistoryWidget extends StatefulWidget {
  const ReplayHistoryWidget({super.key});

  @override
  State<ReplayHistoryWidget> createState() => _ReplayHistoryWidgetState();
}

class _ReplayHistoryWidgetState extends State<ReplayHistoryWidget> {
  bool _areButtonsDisabled = false;

  Widget _buildReplayList(List<swagger.ReceiveReplayDto> replays) {
    final children = replays.reversed.map((replay) {
      final gameMode = gameModeToString(
        context,
        historyGameModeFromString(replay.gameMode.value),
      );
      final time = DateFormat('yyyy-MM-dd – h:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(replay.events[0].time.toInt()),
      );

      return ListTile(
        title: Text(gameMode),
        subtitle: Text(time),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _areButtonsDisabled
                  ? null
                  : () {
                      _openReplayView(context, replay);
                    },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _areButtonsDisabled
                  ? null
                  : () {
                      _deleteReplay(replay);
                    },
            ),
          ],
        ),
      );
    }).toList();

    return Column(
      children: children,
    );
  }

  void _openReplayView(
      BuildContext context, swagger.ReceiveReplayDto replay) async {
    setState(() {
      _areButtonsDisabled = true;
    });

    final response = await GetIt.I
        .get<swagger.Api>()
        .apiGameTemplateIdGet(id: replay.gameTemplateId);

    if (!context.mounted) return;
    await navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => ReplayView(
          replayDto: replay,
          gameTemplate: response.body!,
          isSaveButtonHidden: true,
        ),
      ),
    );

    setState(() {
      _areButtonsDisabled = false;
    });
  }

  void _deleteReplay(swagger.ReceiveReplayDto replay) async {
    setState(() {
      _areButtonsDisabled = true;
    });
    await GetIt.I
        .get<swagger.Api>()
        .apiUserDeleteReplayReplayIdDelete(replayId: replay.id);
    setState(() {
      _areButtonsDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final body = snapshot.data!.body!;

            if (body.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noReplays),
              );
            }

            GetIt.I<LogService>().debug(body.length.toString());
            return _buildReplayList(body);
          },
          future: GetIt.I.get<swagger.Api>().apiUserReplaysGet(),
        ))
      ],
    );
  }
}
