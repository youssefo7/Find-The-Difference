import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/generated/api.swagger.dart' as api;
import 'package:mobile/src/settings/settings_constants.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsService get _settingsService => GetIt.I.get<SettingsService>();

  Locale _locale = Locale(Intl.getCurrentLocale());

  Locale get locale => _locale;

  List<String> get themeColors => defualtThemeColors;

  String _primaryColor = defaultColor;

  ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: parseColor(_primaryColor)),
      );

  set primaryColor(String newPrimaryColor) {
    _primaryColor = newPrimaryColor;
    notifyListeners();
    GetIt.I
        .get<api.Api>()
        .apiUserThemePatch(body: api.Theme(primaryColor: '#$_primaryColor'));
  }

  String get primaryColor => _primaryColor;

  Color parseColor(String color) {
    return Color(int.parse('0xFF$color'));
  }

  Future<void> loadSettings() async {
    final theme = await _settingsService.getTheme();
    if (theme != null) {
      _primaryColor = theme.primaryColor.substring(1);
    }
    _locale = await _settingsService.getLocale();
    notifyListeners();
  }

  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null || newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();

    await GetIt.I.get<api.Api>().apiUserLocalePatch(
        body: api.LocaleDto(locale: newLocale.languageCode));
  }
}
