import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/chat/chat_model.dart';
import 'package:mobile/src/game_page/game_constants.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/user/user_service.dart';
import 'package:mobile/src/userProfile/user_profile_model.dart';

class GameObservers extends StatefulWidget {
  final List<Username> observers;

  const GameObservers({super.key, List<Username>? observers})
      : observers = observers ?? const [];

  @override
  GameObserversState createState() => GameObserversState();
}

class GameObserversState extends State<GameObservers> {
  final _socketIoService = GetIt.I.get<SocketIoService>();

  @override
  void initState() {
    super.initState();
    _listenObserverUpdates();
  }

  @override
  void dispose() {
    _socketIoService.off(GameManagerEvent.observerLeavedEvent);
    _socketIoService.off(GameManagerEvent.observerJoinedEvent);
    super.dispose();
  }

  void _listenObserverUpdates() {
    _socketIoService.on(GameManagerEvent.observerLeavedEvent, (username) {
      UsernameDto observerDto = UsernameDto.fromJson(username);
      if (observerDto.username == serverUsername) return;
      setState(() {
        widget.observers.remove(observerDto.username);
      });
    });

    _socketIoService.on(GameManagerEvent.observerJoinedEvent, (username) {
      UsernameDto observerDto = UsernameDto.fromJson(username);
      if (observerDto.username == serverUsername) return;
      setState(() {
        widget.observers.add(observerDto.username);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.observers.isEmpty) return const SizedBox();

    List<Widget> observerWidgets = widget.observers.map((username) {
      UserProfile userProfile =
          GetIt.I.get<UserService>().getUserByUsername(username);
      String avatarUrl = userProfile.avatarUrl ?? defaultAvatarUrl;

      return Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 16, // Adjust size as needed
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(username),
            ),
          ],
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.visibility, size: 34),
            const SizedBox(width: 4),
            Text('${AppLocalizations.of(context)!.observers}: ',
                style: const TextStyle(fontSize: 20)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: observerWidgets),
            ),
          ],
        ),
      ),
    );
  }
}
