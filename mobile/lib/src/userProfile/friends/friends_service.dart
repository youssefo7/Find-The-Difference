import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class FriendsService {
  SocketIoService get _socketService => GetIt.I<SocketIoService>();
  Api get _api => GetIt.I<Api>();

  Future<List<Username>?> getAllFriends() async {
    try {
      final response = await _api.apiFriendsFriendListGet();
      if (response.statusCode == 200) {
        return response.body;
      } else {
        GetIt.I
            .get<LogService>()
            .error('Failed to get all friends: ${response.error}');
      }
    } catch (e) {
      GetIt.I
          .get<LogService>()
          .error('Exception when calling Api.apiFriendsFriendListGet: $e');
    }
    return null;
  }

  Future<List<Username>?> getAllOutgoingFriendRequests() async {
    try {
      final response = await _api.apiFriendsOutgoingRequestListGet();
      if (response.statusCode == 200) {
        return response.body;
      }
      GetIt.I.get<LogService>().error(
          'Failed to get all outgoing friend requests: ${response.error}');
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling Api.apiFriendsOutgoingRequestListGet: $e');
    }
    return null;
  }

  Future<List<Username>?> getAllIncomingFriendRequests() async {
    try {
      final response = await _api.apiFriendsIncomingRequestListGet();
      if (response.statusCode == 200) {
        return response.body;
      }
      GetIt.I.get<LogService>().error(
          'Failed to get all incoming Friend Requests: ${response.error}');
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling Api.apiFriendsIncomingRequestListGet: $e');
    }
    return null;
  }

  Future<List<Username>?> getAllFriendsByUsername(Username username) async {
    try {
      final response =
          await _api.apiFriendsFriendListUsernameGet(username: username);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        GetIt.I
            .get<LogService>()
            .error('Failed to get all friends of $username: ${response.error}');
      }
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling Api.apiFriendsFriendListUsernameGet: $e');
    }
    return null;
  }

  void addFriend(Username username) async {
    _socketService
        .emit(GameManagerEvent.requestOrAcceptFriend, {'username': username});
  }

  void acceptFriendRequest(Username username) async {
    _socketService
        .emit(GameManagerEvent.requestOrAcceptFriend, {'username': username});
  }

  void removeFriend(Username username) async {
    _socketService
        .emit(GameManagerEvent.refuseOrRemoveFriend, {'username': username});
  }

  void declineFriendRequest(Username username) async {
    _socketService
        .emit(GameManagerEvent.refuseOrRemoveFriend, {'username': username});
  }
}
