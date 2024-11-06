import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/chat/chat_controller.dart';
import 'package:mobile/src/chat/chat_model.dart';
import 'package:mobile/src/chat/sticker_picker.dart';
import 'package:mobile/src/settings/settings_controller.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages(this.chat, {super.key});

  final ClientChat chat;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showStickerPicker = false;

  // To prevent the scroll to be triggered multiple times in parallel
  bool _isScrolling = false;

  ChatController get _chatController => GetIt.I<ChatController>();

  SettingsController get _settingsController =>
      GetIt.I.get<SettingsController>();

  @override
  void initState() {
    super.initState();

    _chatController.messageInSelectedChatNotifier.addListener(() {
      _scrollToBottom(force: true);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _chatController.messageInSelectedChatNotifier.removeListener(() {
      _scrollToBottom(force: true);
    });
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scrollToBottom();
  }

  void _scrollToBottom({bool force = false}) async {
    if (_isScrolling || !mounted) {
      return;
    }

    _isScrolling = true;
    // Loop until the scroll is at the bottom
    while (_scrollController.position.maxScrollExtent !=
        _scrollController.position.pixels) {
      if (!force) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    _isScrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _header,
          Expanded(
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  children: _messagesTiles,
                ),
                if (_showStickerPicker) _stickerPickerWidget(),
              ],
            ),
          ),
          _messageInput,
        ],
      ),
    );
  }

  Row get _header {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            child: Text(
              widget.chat.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _chatController.unselectChat();
          },
        ),
      ],
    );
  }

  Container getMessageWidget(ClientMessage message, bool isStickerGif) {
    final content =
        message.isFromServer && _settingsController.locale.languageCode == 'fr'
            ? message.frenchContent
            : message.content;
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: message.isFromServer
            ? null
            : Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: message.isFromServer ? null : Theme.of(context).cardColor,
      ),
      child: isStickerGif
          ? Image.network(
              content,
              width: 100,
              height: 100,
            )
          : Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: message.isFromServer
                    ? null
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
    );
  }

  Text getUserNameWidget(String username) {
    return Text(
      username,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Padding getAvatarWidget(String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
    );
  }

  List<Align> get _messagesTiles {
    return widget.chat.messages.map((message) {
      const String baseUrl = 'https://polydiff.s3.ca-central-1.amazonaws.com';
      final isUserSender = message.sender == _chatController.username;
      Uri? parsedUri = Uri.tryParse(message.content);
      final isStickerOrGif = message.content.startsWith(baseUrl) &&
          (parsedUri != null && parsedUri.toString() == message.content);

      return Align(
        alignment: isUserSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUserSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!message.isFromServer && !isUserSender)
              getUserNameWidget(message.sender),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isUserSender
                  ? MainAxisAlignment.end
                  : message.isFromServer
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: [
                if (!message.isFromServer && !isUserSender)
                  getAvatarWidget(message.senderAvatar),
                Flexible(child: getMessageWidget(message, isStickerOrGif)),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  void _toggleStickerPicker() {
    setState(() {
      _showStickerPicker = !_showStickerPicker;
    });
  }

  void onStickerSelected(String stickerUrl, bool isSticker) {
    _chatController.sendMessage(stickerUrl);
    _toggleStickerPicker();
  }

  Row get _messageInput {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.sticky_note_2_outlined),
          onPressed: _toggleStickerPicker,
        ),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: AppLocalizations.of(context)!.message,
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (text) {
              text = text.trim();
              if (text.isNotEmpty) {
                _chatController.sendMessage(text);
                _messageController.clear();
              }
            },
          ),
        ),
        IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              String text = _messageController.text.trim();
              if (text.isNotEmpty) {
                _chatController.sendMessage(text);
                _messageController.clear();
              }
            }),
      ],
    );
  }

  Widget _stickerPickerWidget() {
    const double inputBoxHeight = 50;
    const double pickerHeight = 275;

    return Visibility(
      visible: _showStickerPicker,
      child: Positioned(
        bottom: inputBoxHeight,
        left: 0,
        right: 0,
        child: Container(
          height: pickerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: StickerPicker(
            onStickerSelected: onStickerSelected,
          ),
        ),
      ),
    );
  }
}
