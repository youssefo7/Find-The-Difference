import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart' as api;
import 'package:mobile/src/game_page/game_page_view.dart';
import 'package:mobile/src/main_view.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/selection_page/game_config_dialog.dart';
import 'package:mobile/src/selection_page/selection_page_view.dart';
import 'package:mobile/src/services/balance_service.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/userProfile/game_mode_to_string.dart';
import 'package:mobile/src/waiting_lobby/waiting_lobby_view.dart';

class InfoCard extends StatefulWidget {
  final api.GameTemplate gameTemplate;
  final PageType pageType;
  final WaitingGameDto? waitingGameDto;
  final api.HistoryGameMode? gameMode;
  final ObserverGameDto? observerGameDto;
  final Function? fetchGamesCallback;

  const InfoCard(
      {super.key,
      required this.gameTemplate,
      required this.pageType,
      this.waitingGameDto,
      this.gameMode,
      this.observerGameDto,
      this.fetchGamesCallback})
      : assert((pageType == PageType.joinGame) == (waitingGameDto != null)),
        assert((pageType == PageType.observeGame) == (observerGameDto != null)),
        assert((pageType == PageType.createGame) == (gameMode != null));

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  BalanceService get _balanceService => GetIt.I<BalanceService>();

  num get _balance => _balanceService.balance;

  bool _isPurchasing = false;

  void Function() _onTap(BuildContext context) {
    switch (widget.pageType) {
      case PageType.createGame:
        return _onTapCreateGame(context);
      case PageType.joinGame:
        return _onTapJoinGame(context);
      case PageType.market:
        return _onTapBuyGame(context);
      case PageType.observeGame:
        return _onTapObserveGame(context);
    }
  }

  void Function() _onTapCreateGame(BuildContext context) {
    return () {
      final gameMode = widget.gameMode!;

      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return GameConfigDialog(
            gameTemplate: widget.gameTemplate,
            gameMode: gameMode,
          );
        },
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final url =
        GetIt.I.get<BucketService>().getFullUrl(widget.gameTemplate.firstImage);
    final creator = AppLocalizations.of(context)!.creator;
    final players = AppLocalizations.of(context)!.players;
    final numberOfDifferences =
        AppLocalizations.of(context)!.numberOfDifferences;
    const currency = '\$';

    final bool canBuy = hasSufficientFunds();
    final bool isMarket = widget.pageType == PageType.market;
    final borderColor = isMarket && !canBuy ? Colors.red : Colors.grey;
    final borderWidth = isMarket && !canBuy ? 5.0 : 2.0;

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: canBuy || !isMarket ? _onTap(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(url, fit: BoxFit.fill),
                if (isMarket)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart,
                            color: Colors.white, size: 25),
                        const SizedBox(width: 6),
                        Text('$currency${widget.gameTemplate.price.round()}',
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatGameTitle(
                        widget.gameTemplate.name, gameModeString(context)),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.gameTemplate.nGroups.round() != -1)
                    Text(
                      '$numberOfDifferences: ${widget.gameTemplate.nGroups.round()}',
                    ),
                  if (widget.waitingGameDto != null)
                    Text('$creator: ${widget.waitingGameDto!.creator}'),
                  if (widget.waitingGameDto != null)
                    Text(
                        '$players: ${widget.waitingGameDto!.players.join(', ')}'),
                  if (widget.observerGameDto != null)
                    Text(
                        '$players: ${widget.observerGameDto!.players.join(', ')}'),
                  if (widget.observerGameDto != null)
                    Text(
                      widget.observerGameDto!.hasObservers
                          ? AppLocalizations.of(context)!.hasObservers
                          : AppLocalizations.of(context)!.noObservers,
                    ),
                  if (!canBuy && isMarket)
                    Text(AppLocalizations.of(context)!.insufficientFunds,
                        style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool hasSufficientFunds() {
    return _balance >= widget.gameTemplate.price;
  }

  Future<void> _performPurchase(BuildContext context) async {
    if (_isPurchasing) return;
    setState(() {
      _isPurchasing = true;
    });
    final api.BuyGameDto body =
        api.BuyGameDto(gameTemplateId: widget.gameTemplate.id);
    await GetIt.I
        .get<api.Api>()
        .apiMarketBuyGamePost(body: body)
        .then((response) {
      if (response.isSuccessful && widget.fetchGamesCallback != null) {
        widget.fetchGamesCallback!().then((_) async {
          setState(() {
            _isPurchasing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.purchaseSuccessful)),
          );
          await GetIt.I.get<BalanceService>().fetchBalance();
        });
      }
    }).catchError((error) {
      setState(() {
        _isPurchasing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.purchaseFailed)),
      );
    });
  }

  void Function() _onTapBuyGame(BuildContext context) {
    return () {
      _showBuyConfirmationDialog(context);
    };
  }

  void _showBuyConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmPurchase),
          content: Text(
              '${AppLocalizations.of(context)!.confirmPurchaseMessage} ${widget.gameTemplate.price.round()} ?'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              onPressed: _isPurchasing
                  ? null
                  : () async {
                      // Disable button if purchasing
                      await _performPurchase(context);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(); // Dismiss the dialog
                      }
                    },
              child: Text(AppLocalizations.of(context)!.confirm),
            )
          ],
        );
      },
    );
  }

  void Function() _onTapJoinGame(BuildContext context) {
    return () {
      final dto = widget.waitingGameDto!;

      GetIt.I.get<SocketIoService>().emit(
            GameManagerEvent.joinGame,
            JoinGameDto(instanceId: dto.instanceId).toJson(),
          );
      navigatorKey.currentState!.push(
        MaterialPageRoute(
            builder: (context) => WaitingLobbyView(
                  gameTemplate: widget.gameTemplate,
                  gameMode: dto.gameMode,
                )),
      );
    };
  }

  String formatGameTitle(String name, String modeString) {
    if (name.isNotEmpty && modeString.isNotEmpty) {
      return '${name.toUpperCase()} - $modeString';
    } else {
      return name.isNotEmpty ? name.toUpperCase() : modeString;
    }
  }

  String gameModeString(BuildContext context) {
    if (widget.pageType == PageType.observeGame) {
      return gameModeToString(context, widget.observerGameDto!.gameMode);
    }
    if (widget.pageType == PageType.joinGame) {
      return gameModeToString(context, widget.waitingGameDto!.gameMode);
    }
    return '';
  }

  void Function() _onTapObserveGame(BuildContext context) {
    return () {
      final dto = widget.observerGameDto!;
      navigatorKey.currentState!.push(
        MaterialPageRoute(
            builder: (context) => GamePageView(
                  gameTemplate: widget.gameTemplate,
                  gameMode: dto.gameMode,
                  observerGameDto: dto,
                  isObserver: true,
                )),
      );
    };
  }
}
