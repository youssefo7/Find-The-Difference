import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/src/chat/chat_controller.dart';
import 'package:mobile/src/chat/chat_model.dart';

class ChatSearchView extends StatefulWidget {
  const ChatSearchView(this._chatController, {super.key});
  final ChatController _chatController;

  @override
  State<ChatSearchView> createState() => _ChatSearchViewState();
}

class _ChatSearchViewState extends State<ChatSearchView> {
  final _searchBarFocusNode = FocusNode();
  final _searchBarController = TextEditingController();

  bool _shouldShowAvailableChats = false;

  @override
  void initState() {
    _searchBarFocusNode.addListener(() {
      setState(() {
        if (_searchBarFocusNode.hasFocus) {
          _shouldShowAvailableChats = true;
        } else {
          // Delay hiding the available chats to allow the user to click on a chat.
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            setState(() {
              _shouldShowAvailableChats = false;
            });
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _searchBarController,
        builder: (BuildContext context, Widget? child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchBarLabel,
                const SizedBox(height: 8),
                _searchBar,
                if (_shouldShowAvailableChats &&
                    widget._chatController.notjoinedChats.isNotEmpty)
                  _notJoinedChatsList,
              ]);
        });
  }

  Text get _searchBarLabel {
    return Text(
      AppLocalizations.of(context)!.joinChat,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  TextField get _searchBar {
    return TextField(
      enabled: widget._chatController.notjoinedChats.isNotEmpty,
      focusNode: _searchBarFocusNode,
      controller: _searchBarController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget._chatController.notjoinedChats.isNotEmpty
            ? AppLocalizations.of(context)!.searchForAChat
            : AppLocalizations.of(context)!.noChatToJoin,
        suffixIcon: const Icon(Icons.search),
      ),
    );
  }

  DecoratedBox get _notJoinedChatsList {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _notjoinedChatsTiles,
          ),
        ),
      ),
    );
  }

  List<ListTile> get _notjoinedChatsTiles {
    return filteredNotjoinedChats
        .map((chat) => ListTile(
              title: Text(chat.name),
              onTap: () {
                setState(() {
                  _shouldShowAvailableChats = false;
                });
                widget._chatController.joinChat(chat.chatId);
              },
            ))
        .toList();
  }

  List<ClientChat> get filteredNotjoinedChats {
    return widget._chatController.notjoinedChats
        .where((chat) => chat.name
            .toLowerCase()
            .contains(_searchBarController.text.trim().toLowerCase()))
        .toList();
  }
}
