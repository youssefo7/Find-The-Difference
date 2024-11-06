import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/localization_service.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/snackbar_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/friends/friends_service.dart';

class FriendsController with ChangeNotifier {
  List<Username> friendList = [];
  List<Username> outgoingRequestList = [];
  List<Username> incomingRequestList = [];

  SocketIoService get _socketService => GetIt.I<SocketIoService>();
  FriendsService get _friendsService => GetIt.I<FriendsService>();
  SnackBarService get _snackBarService => GetIt.I<SnackBarService>();
  LocalizationService get _localizationService =>
      GetIt.I<LocalizationService>();

  AppLocalizations get _appLocalizations =>
      _localizationService.appLocalizations;

  @override
  dispose() {
    _socketService.off(GameManagerEvent.notifyNewFriendRequest);
    _socketService.off(GameManagerEvent.notifyNewFriend);
    _socketService.off(GameManagerEvent.notifyFriendRemoved);
    _socketService.off(GameManagerEvent.notifyFriendRequestRefused);
    super.dispose();
  }

  Future<void> initialize() async {
    listenForUpdates();
    await getAllFriends();
    await getAllOutgoingFriendRequests();
    await getAllIncomingFriendRequests();
  }

  void listenForUpdates() {
    _socketService.on(GameManagerEvent.notifyNewFriendRequest, (data) {
      getAllIncomingFriendRequests();
      _snackBarService.enqueueSnackBar(
          '${data["username"]}${_appLocalizations.sentYouFriendReq}');
    });

    _socketService.on(GameManagerEvent.notifyNewFriend, (data) {
      getAllFriends();
      getAllOutgoingFriendRequests();
      _snackBarService.enqueueSnackBar(
          '${data["username"]}${_appLocalizations.isNowYourFriend}');
    });

    _socketService.on(GameManagerEvent.notifyFriendRemoved, (data) {
      getAllFriends();
      _snackBarService.enqueueSnackBar(
          '${data["username"]}${_appLocalizations.isNolongerYourFriend}');
    });

    _socketService.on(GameManagerEvent.notifyFriendRequestRefused, (data) {
      getAllOutgoingFriendRequests();
      _snackBarService.enqueueSnackBar(
          '${data["username"]}${_appLocalizations.rejectedFriendRequest}');
    });
  }

  Future<void> getAllFriends() async {
    try {
      final response = await _friendsService.getAllFriends();
      if (response != null) {
        friendList = response;
        notifyListeners();
      }
    } catch (e) {
      GetIt.I
          .get<LogService>()
          .error('Exception when calling _friendsService.getAllFriends: $e');
    }
  }

  Future<void> getAllOutgoingFriendRequests() async {
    try {
      final response = await _friendsService.getAllOutgoingFriendRequests();
      if (response != null) {
        outgoingRequestList = response;
        notifyListeners();
      }
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling _friendsService.getAllOutgoingFriendRequests: $e');
    }
  }

  Future<void> getAllIncomingFriendRequests() async {
    try {
      final response = await _friendsService.getAllIncomingFriendRequests();
      if (response != null) {
        incomingRequestList = response;
        notifyListeners();
      }
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling _friendsService.getAllIncomingFriendRequests: $e');
    }
  }

  Future<List<Username>?> getAllFriendsByUsername(Username username) async {
    try {
      final response = await _friendsService.getAllFriendsByUsername(username);
      if (response != null) {
        return response;
      }
    } catch (e) {
      GetIt.I.get<LogService>().error(
          'Exception when calling _friendsService.getAllFriendsByUsername: $e');
    }
    return null;
  }

  void addFriend(Username username) {
    _friendsService.addFriend(username);
    outgoingRequestList.add(username);
    notifyListeners();
  }

  void acceptFriendRequest(Username username) {
    _friendsService.acceptFriendRequest(username);
    incomingRequestList.remove(username);
    friendList.add(username);
    notifyListeners();
  }

  void removeFriend(Username username) {
    _friendsService.removeFriend(username);
    friendList.remove(username);
    notifyListeners();
  }

  void declineFriendRequest(Username username) {
    _friendsService.declineFriendRequest(username);
    incomingRequestList.remove(username);
    notifyListeners();
  }

  bool isFriend(Username username) => friendList.contains(username);
  bool isOutgoingRequestPending(Username username) =>
      outgoingRequestList.contains(username);
  bool isIncomingRequestPending(Username username) =>
      incomingRequestList.contains(username);
}
