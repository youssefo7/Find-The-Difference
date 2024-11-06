import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/userProfile/profile_tab/profile_widget.dart';

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .profileAppBarTitle(GetIt.I.get<AuthController>().getUsername())),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => GetIt.I.get<AuthController>().logout(false),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: const ProfileWidget(),
    );
  }
}
