import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';

class AccountHistoryService {
  Future<List<AccountHistory>> fetchAccountHistory(String username) async {
    final response = await GetIt.I
        .get<Api>()
        .apiAccountHistoryUsernameGet(username: username);
    return response.body ?? [];
  }
}
