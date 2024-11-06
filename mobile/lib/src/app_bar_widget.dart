import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/avatar/avatar_notifier.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/services/balance_service.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/user/user_service.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String pageTitle;
  final bool isGamePage;
  final List<Tab>? tabs;

  const AppBarWidget({
    super.key,
    required this.pageTitle,
    this.isGamePage = false,
    this.tabs,
  });

  @override
  AppBarWidgetState createState() => AppBarWidgetState();

  @override
  Size get preferredSize {
    final double height =
        tabs == null ? kToolbarHeight : kToolbarHeight + kTextTabBarHeight;
    return Size.fromHeight(height);
  }
}

class AppBarWidgetState extends State<AppBarWidget> {
  UserService get _userService => GetIt.I<UserService>();
  BalanceService get _balanceService => GetIt.I<BalanceService>();
  AuthController get _authController => GetIt.I<AuthController>();
  AvatarNotifier get _avatarNotifier => GetIt.I<AvatarNotifier>();

  String get _username => _authController.getUsername();

  num get _balance => _balanceService.balance;

  @override
  void initState() {
    super.initState();
    _userService.getProfile().then((value) => setState(() {
          _avatarNotifier.updateAvatarUrl(value.avatarUrl);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge(
            [_balanceService, _authController, _avatarNotifier]),
        builder: (context, child) => FutureBuilder(
            future: _userService.getAllUsers().then(
                  (value) =>
                      Future.value(_userService.getUserByUsername(_username)),
                ),
            builder: (context, snapshot) => snapshot.data == null
                ? Container()
                : AppBar(
                    automaticallyImplyLeading: !widget.isGamePage,
                    title: Text(widget.pageTitle),
                    bottom:
                        widget.tabs != null ? TabBar(tabs: widget.tabs!) : null,
                    actions: [
                      Row(children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_money),
                            Text(
                              _balance.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        if (snapshot.data!.avatarUrl != null &&
                            snapshot.data!.avatarUrl!.isNotEmpty)
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              GetIt.I
                                  .get<BucketService>()
                                  .getFullUrl(snapshot.data!.avatarUrl ?? ''),
                            ),
                          ),
                        const SizedBox(width: 100),
                        if (widget.isGamePage)
                          TextButton(
                            onPressed: () {
                              navigatorKey.currentState!
                                  .popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: Text(AppLocalizations.of(context)!.quitGame),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => _authController.logout(false),
                            tooltip: AppLocalizations.of(context)!.logOut,
                            color: Colors.red,
                          ),
                        const SizedBox(width: 10),
                      ]),
                    ],
                  )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
