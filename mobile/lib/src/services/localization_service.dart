import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/settings/settings_controller.dart';

class LocalizationService extends ChangeNotifier {
  SettingsController get _settingsController =>
      GetIt.I.get<SettingsController>();

  AppLocalizations get appLocalizations =>
      lookupAppLocalizations(_settingsController.locale);
}
