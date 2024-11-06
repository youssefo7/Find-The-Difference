import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/chat/chat_controller.dart';
import 'package:mobile/src/chat/chat_drawer_view.dart';
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/home_page/home_page_view.dart';
import 'package:mobile/src/replay/recording_service.dart';
import 'package:mobile/src/services/balance_service.dart';
import 'package:mobile/src/settings/settings_controller.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/friends_controller.dart';

final mainScaffoldKey = GlobalKey<ScaffoldState>();

final navigatorKey = GlobalKey<NavigatorState>();

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with WidgetsBindingObserver {
  bool _isInitialized = false;

  ChatController get _chatController => GetIt.I.get<ChatController>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    connexionInitialization();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnectionCleanup();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isInitialized) _chatController.appLifecycleState = state;
  }

  void connexionInitialization() async {
    GetIt.I.registerSingleton(UserService());
    await GetIt.I.get<UserService>().initialize();

    GetIt.I.registerSingleton(ChatController());
    await GetIt.I.get<ChatController>().initialize();

    GetIt.I.registerSingleton(FriendsController());
    await GetIt.I.get<FriendsController>().initialize();

    GetIt.I.registerSingleton(BalanceService());
    await GetIt.I.get<BalanceService>().initialize();

    await GetIt.I.get<SettingsController>().loadSettings();

    GetIt.I.registerSingleton(ImageController());
    GetIt.I.registerSingleton(RecordingService());

    setState(() {
      _isInitialized = true;
    });
  }

  void disconnectionCleanup() {
    GetIt.I.get<FriendsController>().dispose();
    GetIt.I.unregister<FriendsController>();

    GetIt.I.get<ChatController>().dispose();
    GetIt.I.unregister<ChatController>();

    GetIt.I.get<UserService>().dispose();
    GetIt.I.unregister<UserService>();

    GetIt.I.get<BalanceService>().dispose();
    GetIt.I.unregister<BalanceService>();

    GetIt.I.get<ImageController>().dispose();
    GetIt.I.unregister<ImageController>();
    GetIt.I.unregister<RecordingService>();
  }

  AuthController get authController => GetIt.I.get<AuthController>();

  void _openEndDrawer() {
    mainScaffoldKey.currentState!.openEndDrawer();
    if (_chatController.joinedChats.length <= 1) {
      _chatController.markAllAsRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? ListenableBuilder(
            listenable: Listenable.merge([
              _chatController,
            ]),
            builder: (context, child) {
              return Scaffold(
                key: mainScaffoldKey,
                endDrawer: const ChatDrawer(),
                endDrawerEnableOpenDragGesture: false,
                floatingActionButton: _floatingActionButton,
                body: Navigator(
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(builder: (context) {
                      return const HomePageView();
                    });
                  },
                  key: navigatorKey,
                ),
              );
            })
        : _loadingView;
  }

  FloatingActionButton get _floatingActionButton {
    return FloatingActionButton(
      onPressed: () {
        _openEndDrawer();
      },
      child: Stack(
        children: [
          const Icon(Icons.chat),
          if (_chatController.hasUnreadMessage)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _loadingView {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
