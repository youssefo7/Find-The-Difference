import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/chat/chat_controller.dart';
import 'package:mobile/src/chat/chat_messages_view.dart';
import 'package:mobile/src/chat/chat_model.dart';
import 'package:mobile/src/chat/chat_search_view.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final Key _chatNameKey = GlobalKey();

  final _chatNameController = TextEditingController();

  ChatController get _chatController => GetIt.I<ChatController>();

  @override
  void initState() {
    _chatController.addListener(() {
      if (!mounted) return;
      _chatController.showError(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _chatController.removeListener(() {
      if (!mounted) return;
      _chatController.showError(context);
    });
    _chatController.unselectChatSilently();
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([
          _chatController,
          _chatNameController,
        ]),
        builder: (context, child) => Column(
              children: [
                Expanded(
                    child: SizedBox(
                  width: 500,
                  child: Drawer(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          SizedBox(
                            height: 100,
                            child: DrawerHeader(
                              child: Text(
                                AppLocalizations.of(context)!.chats,
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        if (_chatController.selectedChat != null)
                          ChatMessages(
                            _chatController.selectedChat!,
                          ),
                        if (_chatController.selectedChat == null)
                          Expanded(
                            child: ListView(
                              children: [
                                _chatsView,
                              ],
                            ),
                          ),
                      ],
                    ),
                  )),
                )),
                // To prevent the keyboard from hiding the input fields
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ));
  }

  get _chatsView {
    return Column(
      children: [
        ChatSearchView(
          _chatController,
        ),
        const SizedBox(height: 16),
        _createChatSection,
        const SizedBox(height: 16),
        _joinedChatsSection,
      ],
    );
  }

  Column get _createChatSection {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        AppLocalizations.of(context)!.createChat,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        key: _chatNameKey, // To prevent focus from being lost
        controller: _chatNameController,
        maxLength: maxChatNameLength,
        decoration: InputDecoration(
          hintText: '${_chatNameController.text.length}/$maxChatNameLength',
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.chatName,
          errorText: (_chatNameController.text.trim().isEmpty &&
                  _chatNameController.text.isNotEmpty)
              ? AppLocalizations.of(context)!.chatNameEmpty
              : null,
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_chatNameController.text.trim().isEmpty ||
                  _chatNameController.text.trim().length > maxChatNameLength) {
                return;
              }
              _chatController.createChat(
                _chatNameController.text.trim(),
              );
              _chatNameController.clear();
            },
          ),
        ),
      ),
    ]);
  }

  Column get _joinedChatsSection {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        AppLocalizations.of(context)!.myChats,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      ..._joinedChatsTiles,
    ]);
  }

  bool _hasUnreadMessages(ClientChat chat) {
    return chat.messages.any((message) => !message.hasBeenRead);
  }

  List<ListTile> get _joinedChatsTiles {
    return _chatController.joinedChats
        .map((chat) => ListTile(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_chatController.canLeaveChat(chat))
                    IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () {
                        _chatController.leaveChat(chat.chatId);
                      },
                    ),
                  if (_chatController.canDeleteChat(chat))
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _chatController.deleteChat(chat.chatId);
                      },
                    ),
                ],
              ),
              title: Row(
                children: [
                  Flexible(
                      child: Text(chat.name, overflow: TextOverflow.ellipsis)),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _hasUnreadMessages(chat)
                          ? Colors.red
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              onTap: () {
                _chatController.selectChat(chat.chatId);
              },
            ))
        .toList();
  }
}
