import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/services/localization_service.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/snackbar_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class BalanceService extends ChangeNotifier {
  num _balance = 0;

  num get balance => _balance;

  Api get _api => GetIt.I<Api>();
  SocketIoService get _socketService => GetIt.I<SocketIoService>();
  SnackBarService get _snackBarService => GetIt.I<SnackBarService>();

  LocalizationService get _localizationService =>
      GetIt.I<LocalizationService>();

  AppLocalizations get _appLocalizations =>
      _localizationService.appLocalizations;

  Future<void> initialize() async {
    listenOnUpdateBalance();
    await fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await _api.apiUserBalanceGet();
      if (response.statusCode == 200) {
        _balance = response.body!;
        notifyListeners();
      } else {
        GetIt.I
            .get<LogService>()
            .error('Failed to get balance: ${response.error}');
      }
    } catch (e) {
      GetIt.I
          .get<LogService>()
          .error('Exception when calling Api.apiUserBalanceGet: $e');
    }
  }

  void listenOnUpdateBalance() {
    _socketService.onUpdateBalance((data) async {
      num oldBalance = _balance;
      await fetchBalance();
      if (data.balance > oldBalance) {
        _snackBarService.enqueueSnackBar(_appLocalizations.gamePurchased);
      }
    });
  }

  @override
  void dispose() {
    _socketService.off(GameManagerEvent.updateBalance);
    super.dispose();
  }
}
