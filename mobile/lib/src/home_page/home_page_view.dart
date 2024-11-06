import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/src/app_bar_widget.dart';
import 'package:mobile/src/home_page/create_game_dialog.dart';
import 'package:mobile/src/home_page/join_or_observe_page.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/profile_page/profile_page_view.dart';
import 'package:mobile/src/selection_page/selection_page_view.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(pageTitle: AppLocalizations.of(context)!.homePage),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/main500x500.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 75)),
                  ),
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateGameDialog();
                        });
                  },
                  child: Text(AppLocalizations.of(context)!.createGame),
                ),
                FilledButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 75)),
                  ),
                  onPressed: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => const JoinOrObserveGamePage(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.joinOrObserveGame,
                      textAlign: TextAlign.center),
                ),
                FilledButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 75)),
                  ),
                  onPressed: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => const SelectionPageView(
                          pageType: PageType.market,
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.market),
                ),
                FilledButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 75)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePageView()),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.profile),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
