import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class UserService extends ChangeNotifier {
  List<UserProfile> userProfiles = [];
  SocketIoService get socketService => GetIt.I<SocketIoService>();
  BucketService get bucketService => GetIt.I<BucketService>();

  Future<void> initialize() async {
    await getAllUsers();
    socketService.on(GameManagerEvent.notifyNewUser, (data) {
      getAllUsers();
    });
  }

  Future<UserDto> getProfile() async {
    final response = await GetIt.I.get<Api>().apiUserProfileGet();
    if (response.body == null) {
      throw Exception('Failed to fetch profile');
    }

    return response.body!;
  }

  Future<void> getAllUsers() async {
    try {
      final response = await GetIt.I.get<Api>().apiUserGet();
      if (response.statusCode == 200) {
        Username currentUserUsername =
            GetIt.I.get<AuthController>().getUsername();
        userProfiles = response.body!
            .map((dynamic item) =>
                UserProfile.fromJson(item as Map<String, dynamic>))
            .toList()
            .cast<UserProfile>();

        for (var user in userProfiles) {
          user.avatarUrl = bucketService.getFullUrl(user.avatarUrl!);
        }

        userProfiles.sort((a, b) => a.username == currentUserUsername ? -1 : 1);
        notifyListeners();
      } else {
        GetIt.I
            .get<LogService>()
            .error('Failed to get all users: ${response.error}');
      }
    } catch (e) {
      GetIt.I
          .get<LogService>()
          .error('Exception when calling Api.apiUserGet: $e');
    }
    return;
  }

  UserProfile getUserByUsername(Username username) {
    return userProfiles.firstWhere((user) => user.username == username,
        orElse: () => UserProfile(username: ''));
  }
}
