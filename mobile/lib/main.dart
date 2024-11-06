import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart' as log;
import 'package:mobile/generated/client_index.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/auth/auth_service.dart';
import 'package:mobile/src/avatar/avatar_notifier.dart';
import 'package:mobile/src/camera/camera_service.dart';
import 'package:mobile/src/replay/replay_service.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/services/http/http_interceptor.dart';
import 'package:mobile/src/services/local_notification_service.dart';
import 'package:mobile/src/services/localization_service.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/snackbar_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/settings/settings_controller.dart';
import 'package:mobile/src/settings/settings_service.dart';
import 'package:mobile/src/userProfile/friends/friends_service.dart';
import 'package:mobile/src/userProfile/history_tab/account_history_service.dart';
import 'package:mobile/src/userProfile/history_tab/game_history_service.dart';
import 'package:mobile/src/userProfile/statistics_tab/statistics_service.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  log.Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Registering the services
  final baseUrl = Uri.parse(
      const String.fromEnvironment('SERVER_URL').replaceAll('/api', ''));
  GetIt.I.registerSingleton(Api.create(
    baseUrl: baseUrl,
    interceptors: [
      HttpLoggingInterceptor(level: Level.basic),
      ChopperJwtInterceptor(),
    ],
  ));
  GetIt.I.registerSingleton(SettingsService());
  GetIt.I.registerSingleton(LogService());
  GetIt.I.registerSingleton(SocketIoService());
  GetIt.I.registerSingleton(AuthService());
  GetIt.I.registerSingleton(CameraService());
  GetIt.I.registerSingleton(BucketService());
  GetIt.I.registerSingleton(AccountHistoryService());
  GetIt.I.registerSingleton(GameHistoryService());
  GetIt.I.registerSingleton(StatisticsService());
  GetIt.I.registerSingleton(FriendsService());
  GetIt.I.registerSingleton(SnackBarService());
  GetIt.I.registerSingleton(LocalNotificationService());
  GetIt.I.registerSingleton(ReplayService());

  // Register the controllers
  GetIt.I.registerSingleton(AuthController());
  GetIt.I.registerSingleton(SettingsController());

  GetIt.I.registerSingleton(AvatarNotifier());

  // Depends on the settings controller
  GetIt.I.registerSingleton(LocalizationService());

  // Initializations
  await GetIt.I.get<CameraService>().initialize();
  await GetIt.I.get<LocalNotificationService>().initialize();

  GetIt.I
      .get<LogService>()
      .log('SERVER_URL : ${const String.fromEnvironment('SERVER_URL')}');
  GetIt.I
      .get<LogService>()
      .log('WS_URL     : ${const String.fromEnvironment('WS_URL')}');
  runApp(const MyApp());
}
