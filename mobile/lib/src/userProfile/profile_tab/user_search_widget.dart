import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/friends/user_list_item_widget.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  UserSearchState createState() => UserSearchState();
}

class UserSearchState extends State<UserSearch> {
  String searchQuery = '';

  UserService get _userService => GetIt.I.get<UserService>();

  List<UserProfile> get _users => _userService.userProfiles
      .where((user) =>
          user.username.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _userService,
      builder: (context, child) => Dialog(
          child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchPlayers,
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return UserListItem(user: user);
                },
              )),
              const SizedBox(height: 16),
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
      )),
    );
  }
}
