import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';

class ChopperJwtInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    final token = GetIt.I.get<AuthController>().token;
    if (token.isNotEmpty) {
      return applyHeader(
        request,
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );
    }
    return request;
  }
}
