import 'package:mobile/src/models/typedef.dart';

class ClientMessage {
  final Username sender;
  final String content;
  final UnixTimeMs timestamp;
  final String senderAvatar;
  final bool isFromServer;
  final String frenchContent;
  bool hasBeenRead;

  ClientMessage(this.sender, this.content, this.timestamp, this.senderAvatar,
      this.hasBeenRead,
      {this.isFromServer = false, this.frenchContent = ''});
}

class ClientChat {
  final ChatId chatId;
  final String name;
  final List<ClientMessage> messages;
  final Username creator;
  bool isJoined;

  ClientChat(
      this.chatId, this.name, this.messages, this.creator, this.isJoined);
}

const serverUsername = 'complex-username-that-should-not-be-seen';

const maxChatNameLength = 10;
