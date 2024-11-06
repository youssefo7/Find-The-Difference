import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/app_bar_widget.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/selection_page/selection_page_view.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class JoinOrObserveGamePage extends StatefulWidget {
  const JoinOrObserveGamePage({super.key});

  @override
  State<JoinOrObserveGamePage> createState() => _JoinOrObserveGamePageState();
}

class _JoinOrObserveGamePageState extends State<JoinOrObserveGamePage> {
  @override
  void dispose() {
    GetIt.I.get<SocketIoService>().off(GameManagerEvent.waitingGames);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBarWidget(
          pageTitle: AppLocalizations.of(context)!.joinOrObserveGame,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.joinGame),
            Tab(text: AppLocalizations.of(context)!.observeGame),
          ],
        ),
        body: const TabBarView(
          children: [
            SelectionPageView(pageType: PageType.joinGame),
            SelectionPageView(pageType: PageType.observeGame),
          ],
        ),
      ),
    );
  }
}
