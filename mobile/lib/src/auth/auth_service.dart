import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class AuthService {
  Future<Response<JwtTokenDto>> login(String username, String password) async {
    return await GetIt.I.get<Api>().apiAuthLoginPost(
          body: LoginDto(username: username, password: password),
        );
  }

  Future<Response<JwtTokenDto>> register(
      String username, String password, String avatarUrl) async {
    String trimmedAvatarUrl = trimURL(avatarUrl);
    return await GetIt.I.get<Api>().apiAuthRegisterPost(
          body: CreateUserDto(
            username: username,
            avatarUrl: trimmedAvatarUrl,
            password: password,
          ),
        );
  }

  String trimURL(String url) {
    return url.replaceFirst(
        'http://polydiff.s3.ca-central-1.amazonaws.com/', '');
  }

  Future<bool> connectWs(
      String token, dynamic Function() disconnectCallback) async {
    return await GetIt.I
        .get<SocketIoService>()
        .connect(token, disconnectCallback);
  }

  void disconnectWs() {
    GetIt.I.get<SocketIoService>().disconnect();
  }
}
