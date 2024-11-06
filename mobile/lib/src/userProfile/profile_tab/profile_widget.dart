import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/settings/settings_view.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/friend_requests.dart';
import 'package:mobile/src/userProfile/friends/friends_tab.dart';
import 'package:mobile/src/userProfile/history_tab/account_history_widget.dart';
import 'package:mobile/src/userProfile/history_tab/game_history_widget.dart';
import 'package:mobile/src/userProfile/history_tab/replay_history_widget.dart';
import 'package:mobile/src/userProfile/profile_tab/profile_card.dart';
import 'package:mobile/src/userProfile/statistics_tab/statistics_widget.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  UserService get _userService => GetIt.I.get<UserService>();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: [
                  FutureBuilder<UserDto>(
                    future: _userService.getProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                            AppLocalizations.of(context)!.errorLoadingProfile);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ProfileCard(
                            username: snapshot.data!.username,
                            avatarURL: snapshot.data!.avatarUrl,
                          ),
                        );
                      }
                    },
                  ),
                  const Expanded(
                    child: FriendsTab(),
                  ),
                  const Expanded(
                    child: FriendRequests(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Column(
              children: [
                const Expanded(flex: 1, child: StatisticsWidget()),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: SettingsView(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: DefaultTabController(
                              length: 3,
                              child: Scaffold(
                                appBar: TabBar(
                                  tabs: [
                                    Tab(
                                        text: AppLocalizations.of(context)!
                                            .accountHistory),
                                    Tab(
                                        text: AppLocalizations.of(context)!
                                            .gameHistory),
                                    Tab(
                                        text: AppLocalizations.of(context)!
                                            .replayHistory),
                                  ],
                                ),
                                body: const TabBarView(
                                  children: [
                                    AccountHistoryWidget(),
                                    GameHistoryWidget(),
                                    ReplayHistoryWidget(),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
