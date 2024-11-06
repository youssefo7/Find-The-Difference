import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';

class GameHistoryService {
  Api get _api => GetIt.I<Api>();

  Future<List<History>> fetchGameHistory(String username) async {
    final response = await _api.apiHistoryUsernameGet(username: username);
    return response.body ?? [];
  }
}
