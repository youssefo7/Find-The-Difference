import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/friends_controller.dart';
import 'package:mobile/src/userProfile/friends/user_list_item_widget.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserProfile user;

  const UserDetailsDialog({super.key, required this.user});

  FriendsController get _friendsController => GetIt.I.get<FriendsController>();
  UserService get _userService => GetIt.I.get<UserService>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([_friendsController, _userService]),
        builder: (context, child) => Dialog(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(user.avatarUrl ?? defaultAvatarUrl),
                      ),
                      Text(user.username, style: const TextStyle(fontSize: 24)),
                      Expanded(
                        child: FutureBuilder<List<Username>?>(
                          future: _friendsController
                              .getAllFriendsByUsername(user.username),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Text(AppLocalizations.of(context)!
                                  .errorFetchingFriends);
                            }
                            var friends = snapshot.data!;
                            if (friends.isEmpty) {
                              return Center(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .userHasNoFriends,
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                              );
                            }
                            return ListView.builder(
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                final friendUsername = friends[index];
                                final user = _userService
                                    .getUserByUsername(friendUsername);
                                return UserListItem(
                                  user: user,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
