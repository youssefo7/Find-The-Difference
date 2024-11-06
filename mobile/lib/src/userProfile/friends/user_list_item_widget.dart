import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/userProfile/friends/friends_controller.dart';
import 'package:mobile/src/userProfile/friends/user_details_dialog.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class UserListItem extends StatelessWidget {
  final UserProfile user;

  const UserListItem({super.key, required this.user});

  get _friendsController => GetIt.I.get<FriendsController>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _friendsController,
        builder: (context, child) => ListTile(
              leading: GestureDetector(
                onTap: () => _openUserDetailsDialog(context, user),
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user.avatarUrl ?? defaultAvatarUrl),
                ),
              ),
              title: GestureDetector(
                onTap: () => _openUserDetailsDialog(context, user),
                child: Text(user.username),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (GetIt.I.get<AuthController>().getUsername() ==
                      user.username)
                    _buildNothing(),
                  if (_friendsController
                      .isIncomingRequestPending(user.username))
                    _buildIncomingRequestActions(context, user.username),
                  if (_friendsController
                      .isOutgoingRequestPending(user.username))
                    _buildPendingRequestIcon(),
                  if (_friendsController.isFriend(user.username))
                    _buildRemoveFriendButton(context, user.username),
                  if (!_friendsController.isFriend(user.username) &&
                      !_friendsController
                          .isIncomingRequestPending(user.username) &&
                      !_friendsController
                          .isOutgoingRequestPending(user.username) &&
                      GetIt.I.get<AuthController>().getUsername() !=
                          user.username)
                    _buildAddFriendButton(context, user.username),
                ],
              ),
            ));
  }

  Widget _buildRemoveFriendButton(BuildContext context, String username) {
    return IconButton(
      icon: const Icon(Icons.person_remove, color: Colors.red),
      onPressed: () => _friendsController.removeFriend(username),
    );
  }

  Widget _buildAddFriendButton(BuildContext context, String username) {
    return IconButton(
      icon: const Icon(Icons.person_add, color: Colors.green),
      onPressed: () => _friendsController.addFriend(username),
    );
  }

  Widget _buildIncomingRequestActions(BuildContext context, Username username) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => _friendsController.acceptFriendRequest(username),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _friendsController.declineFriendRequest(username),
        ),
      ],
    );
  }

  Widget _buildPendingRequestIcon() {
    return const IconButton(
      icon: Icon(Icons.hourglass_empty, color: Colors.grey),
      onPressed: null,
    );
  }

  Widget _buildNothing() {
    return const SizedBox.shrink();
  }

  _openUserDetailsDialog(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }
}
