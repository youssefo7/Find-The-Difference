import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/userProfile/history_tab/game_history_service.dart';

class Statistics {
  final int gamesPlayed;
  final int gamesWon;
  final int differencesFoundRatio;
  final int gamesDuration;

  Statistics({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.differencesFoundRatio,
    required this.gamesDuration,
  });
}

class StatisticsService {
  Api get _api => GetIt.I<Api>();

  GameHistoryService get _gameHistoryService => GetIt.I<GameHistoryService>();

  Future<Statistics> fetchStatistics(String username) async {
    final differencesFoundRatio = await fetchDifferencesFoundRatio(username);
    final gameHistory = await fetchGameHistory(username);
    final gamesPlayed = gameHistory.length;
    final gamesWon = gameHistory
        .where((element) => element.winners.contains(username))
        .length;
    final gamesDuration = gameHistory.isEmpty
        ? 0
        : gameHistory
                .map((e) => e.totalTime)
                .fold(.0, (value, element) => value + element) /
            (gameHistory.length * 1000);
    return Statistics(
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      differencesFoundRatio: differencesFoundRatio,
      gamesDuration: gamesDuration.toInt(),
    );
  }

  Future<int> fetchDifferencesFoundRatio(String username) async {
    final response = await _api.apiUserStatsUsernameGet(username: username);
    if (response.body == null || response.body!.isEmpty) {
      return 0;
    }
    final body = response.body!;
    return body.reduce((value, element) => value + element) *
        100 ~/
        body.length;
  }

  Future<List<History>> fetchGameHistory(String username) {
    return _gameHistoryService.fetchGameHistory(username);
  }

  Future<void> patchStatistics(double differencesFoundRatio) async {
    await _api.apiUserStatsPatch(
        body: DifferenceFoundRatioDto(differenceFound: differencesFoundRatio));
  }
}
