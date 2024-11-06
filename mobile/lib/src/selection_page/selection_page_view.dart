import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/app_bar_widget.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/selection_page/info_card_view.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';

enum PageType { createGame, joinGame, market, observeGame }

class SelectionPageView extends StatefulWidget {
  final PageType pageType;
  final HistoryGameMode? gameMode;

  const SelectionPageView({super.key, required this.pageType, this.gameMode})
      : assert((pageType == PageType.createGame) == (gameMode != null));

  @override
  State<SelectionPageView> createState() => SelectionPageState();
}

class SelectionPageState extends State<SelectionPageView> {
  List<(WaitingGameDto?, GameTemplate)> _games = [];
  List<(ObserverGameDto?, GameTemplate)> _observerGames = [];

  @override
  void initState() {
    super.initState();

    switch (widget.pageType) {
      case PageType.createGame:
        _getAvailableGameTemplates();
        break;
      case PageType.joinGame:
        _listenOnWaitingGames();
        break;
      case PageType.observeGame:
        _listenOnObservableGames();
        break;
      case PageType.market:
        fetchBuyableGames();
        break;
    }
    GetIt.I.get<SocketIoService>().emit(GameManagerEvent.getWaitingGames, null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get _getTitle {
    switch (widget.pageType) {
      case PageType.createGame:
        return '${AppLocalizations.of(context)!.createGame} - ${gameModeToString(context, widget.gameMode!)}';
      case PageType.joinGame:
        return AppLocalizations.of(context)!.joinGame;
      case PageType.market:
        return AppLocalizations.of(context)!.market;
      case PageType.observeGame:
        return AppLocalizations.of(context)!.observeGame;
    }
  }

  List<Widget> get _buildCards {
    if (widget.pageType == PageType.observeGame) {
      return _observerGames.map((t) {
        final (observerGameDto, gameTemplate) = t;
        return InfoCard(
          gameTemplate: gameTemplate,
          pageType: widget.pageType,
          observerGameDto: observerGameDto,
        );
      }).toList();
    }
    return _games.map((t) {
      final (waitingGameDto, gameTemplate) = t;
      return InfoCard(
        gameTemplate: gameTemplate,
        pageType: widget.pageType,
        waitingGameDto: waitingGameDto,
        gameMode: widget.gameMode,
        fetchGamesCallback:
            widget.pageType == PageType.market ? fetchBuyableGames : null,
      );
    }).toList();
  }

  bool _shouldDisplayAppBar() {
    return widget.pageType != PageType.joinGame &&
        widget.pageType != PageType.observeGame;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards;
    final Widget body;

    if (cards.isEmpty) {
      body = Center(
        child: Text(widget.pageType == PageType.market
            ? AppLocalizations.of(context)!.noBuyableGamesAvailable
            : AppLocalizations.of(context)!.noGamesAvailable),
      );
    } else {
      body = GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.all(20),
        childAspectRatio: (widget.pageType == PageType.observeGame ||
                widget.pageType == PageType.joinGame)
            ? 0.90
            : 1,
        children: cards,
      );
    }

    return Scaffold(
      appBar:
          _shouldDisplayAppBar() ? AppBarWidget(pageTitle: _getTitle) : null,
      body: body,
    );
  }

  void _getAvailableGameTemplates() async {
    final response = await GetIt.I.get<Api>().apiMarketAvailableGamesGet();
    setState(() {
      _games =
          response.body!.map((gameTemplate) => (null, gameTemplate)).toList();
    });
  }

  void fetchBuyableGames() async {
    final response = await GetIt.I.get<Api>().apiMarketBuyableGamesGet();
    if (response.isSuccessful && response.body != null) {
      setState(() {
        _games =
            response.body!.map((gameTemplate) => (null, gameTemplate)).toList();
      });
    }
  }

  void _listenOnWaitingGames() {
    GetIt.I.get<SocketIoService>().off(GameManagerEvent.waitingGames);

    GetIt.I.get<SocketIoService>().onWaitingGames((waitingGamesDto) async {
      final waitingGameTemplates =
          waitingGamesDto.waitingGames.map((game) async {
        final GameTemplate gameTemplate;
        if (game.templateId == '') {
          gameTemplate = const GameTemplate(
            id: '',
            name: '',
            difficulty: GameTemplateDifficulty.swaggerGeneratedUnknown,
            firstImage:
                'http://polydiff.s3.ca-central-1.amazonaws.com/time_limited.png',
            secondImage: '',
            nGroups: -1,
            deleted: false,
            price: 0,
            creator: '',
          );
        } else {
          final response = await GetIt.I
              .get<Api>()
              .apiGameTemplateIdGet(id: game.templateId);
          gameTemplate = response.body!;
        }

        return (game, gameTemplate);
      });

      final waitingGamesResult = await Future.wait(waitingGameTemplates);

      setState(() {
        _games = waitingGamesResult;
      });
    });
  }

  void _listenOnObservableGames() {
    GetIt.I.get<SocketIoService>().off(GameManagerEvent.waitingGames);
    GetIt.I.get<SocketIoService>().onWaitingGames((waitingGamesDto) async {
      final waitingGameTemplates =
          waitingGamesDto.observerGames.map((game) async {
        final GameTemplate gameTemplate;
        if (isTimeLimit(game.gameMode)) {
          gameTemplate = const GameTemplate(
            id: '',
            name: '',
            difficulty: GameTemplateDifficulty.swaggerGeneratedUnknown,
            firstImage:
                'http://polydiff.s3.ca-central-1.amazonaws.com/time_limited.png',
            secondImage: '',
            nGroups: -1,
            deleted: false,
            price: 0,
            creator: '',
          );
        } else {
          final response = await GetIt.I
              .get<Api>()
              .apiGameTemplateIdGet(id: game.templateId);
          gameTemplate = response.body!;
        }

        return (game, gameTemplate);
      });

      final result = await Future.wait(waitingGameTemplates);

      setState(() {
        _observerGames = result;
      });
    });
  }
}
