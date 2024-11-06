import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/avatar/avatar_input_view.dart';
import 'package:mobile/src/services/bucket_service.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailController = TextEditingController();

  late TabController _tabController;

  String _avatarUrl = GetIt.I.get<BucketService>().defaultAvatarUrls[0];

  bool _hasTriedToConnect = false;

  bool _shouldObscurePassword = true;

  AuthController get _authController => GetIt.I.get<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _clearInputs();
        _clearErrors();
        _loseFocus();
        setState(() {
          _hasTriedToConnect = false;
        });
      }
    });
  }

  @override
  dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _isLoginTab => _tabController.index == 0;

  bool get _isRegisterTab => _tabController.index == 1;

  bool get _areInputsValid {
    return _usernameController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _authController.isUsernameLengthValid(_usernameController.text) &&
        _authController.isPasswordLengthValid(_passwordController.text) &&
        _authController.isTextFieldStringValid(_usernameController.text) &&
        (!_isRegisterTab ||
            (_authController.isEmailValid(_emailController.text)));
  }

  void _clearInputs() {
    _usernameController.clear();
    _passwordController.clear();
    _emailController.clear();
    _shouldObscurePassword = true;
  }

  void _clearErrors() {
    _authController.clearErrors();
    _authController.usernameChanged = false;
  }

  void _loseFocus() {
    FocusScope.of(context).unfocus();
  }

  String? get _emailErrorText {
    if (_hasTriedToConnect &&
        !_authController.isEmailValid(_emailController.text)) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  String? get _usernameErrorText {
    if (_authController.usernameChanged) {
      return null;
    }
    if (_authController.httpConnectionHasFailed) {
      if (_authController.message == 'User already exists') {
        return AppLocalizations.of(context)!.userAlreadyExists;
      }
      if (_authController.message == 'User already connected') {
        return AppLocalizations.of(context)!.userAlreadyConnected;
      }
      if (_authController.message == 'User does not exist') {
        return AppLocalizations.of(context)!.userDoesNotExist;
      }
    }
    if (_authController.wsConnectionHasFailed) {
      return AppLocalizations.of(context)!.webSocketConnectionFailed;
    }
    if (!_hasTriedToConnect) {
      return null;
    }
    if (_usernameController.text.trim().isEmpty) {
      return AppLocalizations.of(context)!.emptyField;
    }
    if (!_authController.isUsernameLengthValid(_usernameController.text)) {
      return AppLocalizations.of(context)!.usernameLengthLimit;
    }
    if (!_authController.isTextFieldStringValid(_usernameController.text)) {
      return AppLocalizations.of(context)!.fieldPattern;
    }
    return null;
  }

  String? get _passwordErrorText {
    if (_authController.usernameChanged) {
      return null;
    }
    if (_authController.httpConnectionHasFailed &&
        _authController.message == 'Password is invalid') {
      return AppLocalizations.of(context)!.invalidPassword;
    }
    if (!_hasTriedToConnect) {
      return null;
    }
    if (_passwordController.text.trim().isEmpty) {
      return AppLocalizations.of(context)!.emptyField;
    }
    if (_authController.wsConnectionHasFailed) {
      return AppLocalizations.of(context)!.webSocketConnectionFailed;
    }
    if (!_authController.isPasswordLengthValid(_passwordController.text)) {
      return AppLocalizations.of(context)!.passwordLengthLimit;
    }
    return null;
  }

  TextField get _emailInput {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
        errorText: _emailErrorText,
      ),
      maxLength: 100,
      enabled: !_authController.isLoading,
      keyboardType: TextInputType.emailAddress,
    );
  }

  TextField get _usernameInput {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.username,
          errorText: _usernameErrorText),
      maxLength: _authController.usernameMaximumFieldLength,
      enabled: !_authController.isLoading,
    );
  }

  TextField get _passwordInput {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.password,
        errorText: _passwordErrorText,
        suffixIcon: (_passwordController.text.isNotEmpty)
            ? IconButton(
                icon: Icon(
                  _shouldObscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _shouldObscurePassword = !_shouldObscurePassword;
                  });
                },
              )
            : null,
      ),
      maxLength: _authController.passwordMaximumFieldLength,
      enabled: !_authController.isLoading,
      obscureText: _shouldObscurePassword,
    );
  }

  Row get _loginView {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              _usernameInput,
              _passwordInput,
              ElevatedButton(
                onPressed: !_authController.isLoading
                    ? () {
                        setState(() {
                          _hasTriedToConnect = true;
                        });
                        if (_authController.usernameChanged) {
                          _clearErrors();
                        }
                        if (_areInputsValid) {
                          _authController.login(_usernameController.text.trim(),
                              _passwordController.text.trim());
                        }
                      }
                    : null,
                child: Text(AppLocalizations.of(context)!.login),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row get _registerView {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              _emailInput,
              _usernameInput,
              _passwordInput,
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: !_authController.isLoading
                    ? () {
                        setState(() {
                          _hasTriedToConnect = true;
                        });
                        if (_authController.usernameChanged) {
                          _clearErrors();
                        }
                        if (_areInputsValid) {
                          _authController.register(
                              _usernameController.text.trim(),
                              _passwordController.text.trim(),
                              _avatarUrl);
                        }
                      }
                    : null,
                child: Text(AppLocalizations.of(context)!.register),
              )
            ],
          ),
        ),
        const SizedBox(width: 16),
        AvatarInputView(
          onValueChanged: (avatarUrl) {
            setState(() {
              _avatarUrl = avatarUrl;
            });
          },
        ),
      ],
    );
  }

  Center get _authenticationTabsView {
    return Center(
      child: Card(
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.login),
                      Tab(text: AppLocalizations.of(context)!.register),
                    ],
                    controller: _tabController,
                  ),
                  _isLoginTab
                      ? _loginView
                      : _isRegisterTab
                          ? _registerView
                          : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([
          _authController,
          _usernameController,
          _passwordController,
          _emailController,
        ]),
        builder: (context, child) => Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      _authenticationTabsView,
                      if (_authController.isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
