import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/auth/auth_view.dart';
import 'package:mobile/src/main_view.dart';

import 'settings/settings_controller.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  SettingsController get _settingsController =>
      GetIt.I.get<SettingsController>();
  AuthController get _authController => GetIt.I.get<AuthController>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settingsController, _authController]),
      builder: (context, child) => MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        restorationScopeId: 'app',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _settingsController.locale,
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('fr', ''),
        ],
        theme: _settingsController.theme,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        home: _authController.isAuthenticated
            ? const MainView()
            : const AuthView(),
      ),
    );
  }
}
