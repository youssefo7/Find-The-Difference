import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/auth/auth_model.dart';
import 'package:mobile/src/auth/auth_service.dart';
import 'package:mobile/src/avatar/avatar_notifier.dart';

class AuthController with ChangeNotifier {
  bool _httpConnectionEstablished = false;
  bool _wsConnectionEstablished = false;

  // Error flags
  bool _httpConnectionHasFailed = false;
  bool _wsConnectionHasFailed = false;

  bool _isLoading = false;

  String _token = '';
  String _message = '';

  bool get httpConnectionEstablished => _httpConnectionEstablished;
  bool get wsConnectionEstablished => _wsConnectionEstablished;

  bool get httpConnectionHasFailed => _httpConnectionHasFailed;
  bool get wsConnectionHasFailed => _wsConnectionHasFailed;

  bool get isLoading => _isLoading;

  String get token => _token;
  String get message => _message;

  String _username = '';

  bool get isAuthenticated =>
      _httpConnectionEstablished && _wsConnectionEstablished;

  int get usernameMaximumFieldLength => 10;

  int get passwordMaximumFieldLength => 100;

  AvatarNotifier get _avatarNotifier => GetIt.I.get<AvatarNotifier>();

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isUsernameLengthValid(String text) {
    return text.length <= usernameMaximumFieldLength;
  }

  bool isPasswordLengthValid(String text) {
    return text.length <= passwordMaximumFieldLength;
  }

  bool isTextFieldStringValid(String text) {
    return RegExp(r'^[a-z0-9]*$').hasMatch(text);
  }

  bool usernameChanged = false;

  Future<void> login(String username, String password) async {
    _username = username;
    await _establishHttpConnection(
        username, password, HttpAuthenticationType.login);
  }

  Future<void> register(
      String username, String password, String avatarUrl) async {
    _username = username;
    await _establishHttpConnection(
        username, password, HttpAuthenticationType.register, avatarUrl);
  }

  Future<void> updateUsername(BuildContext context, String newUsername) async {
    try {
      final response = await GetIt.I
          .get<Api>()
          .apiUserUsernamePatch(body: UsernameDto(username: newUsername));

      if (response.statusCode == 200) {
        return; // Because of the logout
      } else {
        if (response.error == null) {
          throw Exception('Unknown error');
        }
        String errorMessage =
            ErrorResponseDto.fromJson(jsonDecode(response.error.toString()))
                    .message
                    .value ??
                'Unknown error';
        if (context.mounted) {
          switch (errorMessage) {
            case 'User already exists':
              errorMessage = AppLocalizations.of(context)!.userAlreadyExists;
              break;
            case 'Cannot Rename Admin':
              errorMessage = AppLocalizations.of(context)!.cannotRenameAdmin;
              break;
            default:
              errorMessage = AppLocalizations.of(context)!.unknownError;
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(BuildContext context, String newPassword) async {
    try {
      final response = await GetIt.I.get<Api>().apiAuthChangePasswordPost(
          body: ChangePasswordDto(password: newPassword));

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.passwordChangeSuccess)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.passwordChangeFailure)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
        );
      }
    }
  }

  Future<bool> updateAvatar(BuildContext context, String newAvatarUrl) async {
    try {
      final ChangeAvatarDto dto = ChangeAvatarDto(avatarUrl: newAvatarUrl);
      final response =
          await GetIt.I.get<Api>().apiUserChangeAvatarPatch(body: dto);

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.avatarSuccessfullyChanged)),
          );
          _avatarNotifier.updateAvatarUrl(newAvatarUrl);
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToChangeAvatar),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)),
        );
      }
    }
    return false;
  }

  String getUsername() {
    return _username;
  }

  void clearErrors() {
    _resetErrorFlags();
    notifyListeners();
  }

  void logout(bool wsConnectionHasFailed) {
    if (_httpConnectionEstablished) {
      _httpConnectionEstablished = false;
      _httpConnectionHasFailed = false;
      _isLoading = false;
      _token = '';
    }
    if (_wsConnectionEstablished) {
      _disconnectWs();
    }
    _wsConnectionHasFailed = wsConnectionHasFailed;

    _avatarNotifier.resetAvatarUrl();
    notifyListeners();
  }

  Future<void> _establishHttpConnection(String username, String password,
      HttpAuthenticationType authenticationType,
      [String avatarUrl = '']) async {
    if (username.isEmpty || password.isEmpty) return;
    if (_isLoading) return;
    if (_httpConnectionEstablished) return;

    _resetErrorFlags();
    _isLoading = true;
    notifyListeners();

    try {
      final response = switch (authenticationType) {
        HttpAuthenticationType.login =>
          await GetIt.I.get<AuthService>().login(username, password),
        HttpAuthenticationType.register => await GetIt.I
            .get<AuthService>()
            .register(username, password, avatarUrl),
      };

      if (response.isSuccessful) {
        _httpConnectionEstablished = true;
        _token = response.body!.accessToken;
        await _connectWs();
      } else {
        final error =
            ErrorResponseDto.fromJson(jsonDecode(response.error as String));

        _httpConnectionEstablished = false;
        _token = '';
        _message = error.message.value ?? 'Unknown value';
        _wsConnectionEstablished = false;
        _httpConnectionHasFailed = true;
      }
    } on SocketException {
      _httpConnectionEstablished = false;
      _token = '';
      _message = 'Server is not available';
      _wsConnectionEstablished = false;
      _httpConnectionHasFailed = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _connectWs() async {
    if (_wsConnectionEstablished) return;

    final isSuccessful =
        await GetIt.I.get<AuthService>().connectWs(token, () => logout(true));

    if (isSuccessful) {
      _wsConnectionEstablished = true;
    } else {
      logout(true);
    }
  }

  void _disconnectWs() {
    _wsConnectionEstablished = false;
    GetIt.I.get<AuthService>().disconnectWs();
  }

  void _resetErrorFlags() {
    _httpConnectionHasFailed = false;
    _wsConnectionHasFailed = false;
  }
}
