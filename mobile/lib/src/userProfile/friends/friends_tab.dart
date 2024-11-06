import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/friends_controller.dart';
import 'package:mobile/src/userProfile/friends/user_list_item_widget.dart';
import 'package:mobile/src/userProfile/profile_tab/user_search_widget.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  FriendsController get _friendsController => GetIt.I.get<FriendsController>();
  UserService get _userService => GetIt.I.get<UserService>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([_friendsController, _userService]),
        builder: (context, child) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.myFriends,
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => openSearchModal(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: _friendsController.friendList.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.youHaveNoFriends,
                                style: Theme.of(context).textTheme.titleSmall),
                          )
                        : ListView.builder(
                            itemCount: _friendsController.friendList.length,
                            itemBuilder: (context, index) {
                              final friendUsername =
                                  _friendsController.friendList[index];
                              final user = _userService
                                  .getUserByUsername(friendUsername);
                              return UserListItem(
                                user: user,
                              );
                            },
                          )),
              ],
            ));
  }

  void openSearchModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UserSearch(),
    );
  }
}
