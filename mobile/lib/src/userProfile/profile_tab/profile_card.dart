import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/avatar/avatar_input_view.dart';
import 'package:mobile/src/avatar/avatar_notifier.dart';
import 'package:mobile/src/services/balance_service.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/user/user_service.dart';

class ProfileCard extends StatefulWidget {
  final String username;
  final String avatarURL;

  const ProfileCard(
      {super.key, required this.username, required this.avatarURL});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  BalanceService get _balanceService => GetIt.I<BalanceService>();
  num get _balance => _balanceService.balance;

  AvatarNotifier get _avatarNotifier => GetIt.I.get<AvatarNotifier>();
  UserService get _userService => GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    _avatarNotifier.updateAvatarUrl(widget.avatarURL);
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.6,
          child: Center(
            child: AvatarInputView(
              isEditingMode: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_balanceService, _avatarNotifier]),
      builder: (context, child) => FutureBuilder(
          future: _userService.getAllUsers().then(
                (value) => Future.value(
                    _userService.getUserByUsername(widget.username)),
              ),
          builder: (context, snapshot) => snapshot.data == null
              ? Container()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (snapshot.data!.avatarUrl == null ||
                                snapshot.data!.avatarUrl!.isEmpty)
                            ? null
                            : NetworkImage(GetIt.I
                                .get<BucketService>()
                                .getFullUrl(snapshot.data!.avatarUrl!)),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            mini: true,
                            shape: const CircleBorder(),
                            onPressed: _showAvatarPicker,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_money, size: 30),
                          Text(
                            _balance.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
    );
  }
}
