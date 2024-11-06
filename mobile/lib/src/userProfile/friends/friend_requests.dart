import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/friends_controller.dart';
import 'package:mobile/src/userProfile/friends/user_list_item_widget.dart';

class FriendRequests extends StatefulWidget {
  const FriendRequests({super.key});

  @override
  State<FriendRequests> createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.incomingFriendRequests,
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                Expanded(
                    child: _friendsController.incomingRequestList.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noPendingRequests,
                                style: Theme.of(context).textTheme.titleSmall),
                          )
                        : ListView.builder(
                            itemCount:
                                _friendsController.incomingRequestList.length,
                            itemBuilder: (context, index) {
                              final friendUsername =
                                  _friendsController.incomingRequestList[index];
                              final user = _userService
                                  .getUserByUsername(friendUsername);
                              return UserListItem(user: user);
                            },
                          )),
              ],
            ));
  }
}
