import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/services/log_service.dart';

import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Locale _selectedLocale = GetIt.I.get<SettingsController>().locale;
  String _selectedTheme = GetIt.I.get<SettingsController>().primaryColor;

  bool _shouldObscurePassword = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _authController.getUsername();
  }

  bool get _canSaveUsername =>
      _usernameController.text.trim() != _authController.getUsername() &&
      _usernameController.text.trim().isNotEmpty &&
      _authController.isUsernameLengthValid(_usernameController.text) &&
      _authController.isTextFieldStringValid(_passwordController.text);

  bool get _canSavePassword =>
      _passwordController.text.trim().isNotEmpty &&
      _authController.isPasswordLengthValid(_usernameController.text);

  bool get _canSaveLocale => _selectedLocale != _settingsController.locale;

  bool get _canSaveTheme => _selectedTheme != _settingsController.primaryColor;

  AuthController get _authController => GetIt.I.get<AuthController>();

  SettingsController get _settingsController =>
      GetIt.I.get<SettingsController>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildThemeDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.changeTheme,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (final color in _settingsController.themeColors)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTheme = color;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color: _selectedTheme == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                    backgroundColor: ColorScheme.fromSeed(
                            seedColor: _settingsController.parseColor(color))
                        .primary
                        .withAlpha(150),
                    shape: const CircleBorder(),
                  ),
                  child: const SizedBox(),
                ),
              )
          ]),
        ],
      ),
    );
  }

  Widget _buildLocaleDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.locale,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          DropdownMenu<Locale>(
            label: Text(AppLocalizations.of(context)!.language),
            initialSelection: _settingsController.locale,
            onSelected: (Locale? locale) {
              if (locale == null) {
                return;
              }
              setState(() {
                _selectedLocale = locale;
              });
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: Locale('en'),
                label: 'English',
              ),
              DropdownMenuEntry(
                value: Locale('fr'),
                label: 'Français',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? get _usernameErrorText {
    if (!_authController.isUsernameLengthValid(_usernameController.text)) {
      return AppLocalizations.of(context)!.usernameLengthLimit;
    }
    if (!_authController.isTextFieldStringValid(_usernameController.text)) {
      return AppLocalizations.of(context)!.fieldPattern;
    }
    return null;
  }

  Widget _buildChangeUsername(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.settings,
                  style: const TextStyle(fontSize: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                        maxLength: _authController.usernameMaximumFieldLength,
                        controller: _usernameController,
                        decoration: InputDecoration(
                            helperText: AppLocalizations.of(context)!
                                .disconnectedIfChanged,
                            labelText: AppLocalizations.of(context)!.username,
                            errorText: _usernameErrorText),
                        enabled: !_isSaving),
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  String? get _passwordErrorText {
    if (_authController.wsConnectionHasFailed) {
      return AppLocalizations.of(context)!.webSocketConnectionFailed;
    }
    if (!_authController.isPasswordLengthValid(_passwordController.text)) {
      return AppLocalizations.of(context)!.passwordLengthLimit;
    }
    return null;
  }

  Widget _buildChangePassword(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            width: 300,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _shouldObscurePassword,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.changePassword,
                            hintText:
                                AppLocalizations.of(context)!.enterNewPassword,
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
                                        _shouldObscurePassword =
                                            !_shouldObscurePassword;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          enabled: !_isSaving,
                          maxLength: _authController.passwordMaximumFieldLength,
                        ),
                      ),
                    ],
                  ),
                ])));
  }

  bool get _canSave =>
      !_isSaving &&
      (_canSaveUsername || _canSavePassword || _canSaveLocale || _canSaveTheme);

  _saveUsername() async {
    _authController.usernameChanged = true;
    return _authController.updateUsername(
        context, _usernameController.text.trim());
  }

  _savePassword() async {
    await GetIt.I
        .get<AuthController>()
        .updatePassword(context, _passwordController.text.trim())
        .then((_) {})
        .catchError((error) {
      SnackBar(content: Text(AppLocalizations.of(context)!.submitFailure));
    });
    _passwordController.clear();
  }

  _save() async {
    setState(() {
      _isSaving = true;
    });

    if (_canSavePassword) {
      await _savePassword();
    }

    if (_canSaveLocale) {
      await _settingsController.updateLocale(_selectedLocale);
    }

    if (_canSaveTheme) {
      _settingsController.primaryColor = _selectedTheme;
    }

    // Last because of the logout
    if (_canSaveUsername) {
      await _saveUsername().catchError((error) {
        GetIt.I.get<LogService>().error('Failed to update username: $error');
        setState(() {
          _isSaving = false;
        });
        _usernameController.text = _authController.getUsername();
        _authController.usernameChanged = false;
      });
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge(
          [_usernameController, _passwordController],
        ),
        builder: (context, child) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChangeUsername(context),
                  _buildChangePassword(context),
                  _buildLocaleDropdown(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThemeDropdown(context),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: ElevatedButton(
                          onPressed: _canSave ? _save : null,
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
