import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/user/user_model.dart';
import 'package:mobile/src/userProfile/statistics_tab/statistic_card.dart';
import 'package:mobile/src/userProfile/statistics_tab/statistics_service.dart';

class StatisticsWidget extends StatefulWidget {
  const StatisticsWidget({super.key});

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> {
  late Future<Statistics> statisticsFuture;

  @override
  void initState() {
    super.initState();
    final username = GetIt.I.get<AuthController>().getUsername();
    statisticsFuture =
        GetIt.I.get<StatisticsService>().fetchStatistics(username);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Statistics>(
      future: statisticsFuture,
      builder: (context, snapshot) {
        GetIt.I.get<LogService>().debug(snapshot.toString());
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Text(AppLocalizations.of(context)!.errorLoadingStatistics);
        } else {
          final statisticsData = snapshot.data!;
          final statisticCards = getStatisticData(statisticsData, context);

          return Row(
            children: [
              for (var card in statisticCards)
                Expanded(child: StatisticCard(data: card)),
            ],
          );
        }
      },
    );
  }

  List<StatisticsCardData> getStatisticData(
      Statistics statistics, BuildContext context) {
    final List<StatisticsCardData> statisticCards = [
      StatisticsCardData(
        title: AppLocalizations.of(context)!.gamesPlayed,
        value: statistics.gamesPlayed,
        icon: Icons.games_rounded,
        description: AppLocalizations.of(context)!.gamesPlayedDescription,
      ),
      StatisticsCardData(
        title: AppLocalizations.of(context)!.gamesWon,
        value: statistics.gamesWon,
        icon: Icons.emoji_events_rounded,
        description: AppLocalizations.of(context)!.gamesWonDescription,
      ),
      StatisticsCardData(
        title: AppLocalizations.of(context)!.differencesFound,
        value: statistics.differencesFoundRatio,
        icon: Icons.pie_chart_rounded,
        description: AppLocalizations.of(context)!.differencesFoundDescription,
      ),
      StatisticsCardData(
        title: AppLocalizations.of(context)!.gamesDuration,
        value: statistics.gamesDuration,
        icon: Icons.timer_rounded,
        description: AppLocalizations.of(context)!.gamesDurationDescription,
      ),
    ];
    return statisticCards;
  }
}
