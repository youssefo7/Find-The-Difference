import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/generated/api.swagger.dart' as api;
import 'package:mobile/generated/api.swagger.dart';

class SettingsService {
  Future<Locale> getLocale() async {
    final response = await GetIt.I.get<Api>().apiUserLocaleGet();
    if (response.statusCode == 401) {
      return Locale(Intl.getCurrentLocale());
    }

    return Locale(response.body!.locale);
  }

  Future<api.Theme?> getTheme() async {
    final response = await GetIt.I.get<Api>().apiUserThemeGet();
    return response.body;
  }
}
