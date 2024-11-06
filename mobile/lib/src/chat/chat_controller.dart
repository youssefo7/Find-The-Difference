import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/chat/chat_model.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/models/typedef.dart';
import 'package:mobile/src/services/local_notification_service.dart';
import 'package:mobile/src/services/localization_service.dart';
import 'package:mobile/src/services/log_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';
import 'package:mobile/src/settings/settings_controller.dart';

enum ErrorMessage {
  chatNotFound,
  cannotJoinGameChat,
  cannotLeaveGameChat,
  alreadyInChat,
  notInChat,
  notChatCreator,
  cannotJoinGeneralChat,
  cannotLeaveGeneralChat,
  cannotDeleteGeneralChat,

  chatDeleted,
  chatLeft,
}

class ChatController with ChangeNotifier {
  final Map<ChatId, ClientChat> _chats = {};
  ChatId _generalChatId = '';
  ChatId _selectedChatId = '';

  Username username = GetIt.I.get<AuthController>().getUsername();

  ErrorMessage? _errorMessage;

  final _player = AudioPlayer();

  final _messageInSelectedChatNotifier = ChangeNotifier();

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  Future<void> initialize() async {
    await _getAvailableChats();
    await _getJoinedChats();
    await _getGeneralChatId();

    _listen();

    notifyListeners();
  }

  @override
  void dispose() {
    _socketIoService.off(GameManagerEvent.message);
    _socketIoService.off(GameManagerEvent.chatCreated);
    _socketIoService.off(GameManagerEvent.chatDeleted);
    _socketIoService.off(GameManagerEvent.chatJoined);
    _socketIoService.off(GameManagerEvent.chatLeft);
    _socketIoService.off(GameManagerEvent.chatNotFound);
    _socketIoService.off(GameManagerEvent.cannotJoinGameChat);
    _socketIoService.off(GameManagerEvent.cannotLeaveGameChat);
    _socketIoService.off(GameManagerEvent.alreadyInChat);
    _socketIoService.off(GameManagerEvent.notInChat);
    _socketIoService.off(GameManagerEvent.notChatCreator);
    _socketIoService.off(GameManagerEvent.cannotJoinGeneralChat);
    _socketIoService.off(GameManagerEvent.cannotLeaveGeneralChat);
    _socketIoService.off(GameManagerEvent.cannotDeleteGeneralChat);

    super.dispose();
  }

  set appLifecycleState(AppLifecycleState value) {
    _appLifecycleState = value;
  }

  Api get _api => GetIt.I.get<Api>();

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();

  LogService get _logService => GetIt.I.get<LogService>();

  LocalNotificationService get _localNotificationService =>
      GetIt.I.get<LocalNotificationService>();

  LocalizationService get _localizationService =>
      GetIt.I.get<LocalizationService>();

  SettingsController get _settingsController =>
      GetIt.I.get<SettingsController>();

  AppLocalizations get _appLocalizations =>
      _localizationService.appLocalizations;

  List<ClientChat> get notjoinedChats =>
      _chats.values.where((element) => !element.isJoined).map((chat) {
        chat.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return chat;
      }).toList();

  List<ClientChat> get joinedChats =>
      _chats.values.toList().where((element) => element.isJoined).map((chat) {
        chat.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return chat;
      }).toList();

  ClientChat? get selectedChat => _chats[_selectedChatId];

  ChangeNotifier get messageInSelectedChatNotifier =>
      _messageInSelectedChatNotifier;

  bool get hasUnreadMessage {
    return joinedChats
        .any((chat) => chat.messages.any((message) => !message.hasBeenRead));
  }

  bool canLeaveChat(ClientChat chat) {
    return chat.chatId != _generalChatId;
  }

  bool canDeleteChat(ClientChat chat) {
    return chat.creator == username && chat.chatId != _generalChatId;
  }

  void createChat(String name) {
    _emitCreateChat(ChatNameDto(name: name));
  }

  void deleteChat(ChatId chatId) {
    _emitDeleteChat(ChatIdDto(chatId: chatId));
  }

  void joinChat(ChatId chatId) {
    _emitJoinChat(ChatIdDto(chatId: chatId));
  }

  void leaveChat(ChatId chatId) {
    _emitLeaveChat(ChatIdDto(chatId: chatId));
  }

  void selectChat(ChatId chatId) {
    final chat = _chats[chatId];

    if (chat == null) {
      _logService.error('Chat not found : $chatId');
      return;
    }

    _selectedChatId = chatId;

    for (var message in chat.messages) {
      message.hasBeenRead = true;
    }

    notifyListeners();
  }

  void unselectChatSilently() {
    _selectedChatId = '';
  }

  void unselectChat() {
    unselectChatSilently();
    notifyListeners();
  }

  void sendMessage(String content) {
    final chat = selectedChat;

    if (chat == null) {
      _logService.error('Chat not found : $_selectedChatId');
      return;
    }

    _emitMessage(
        ClientToServerMessageDto(chatId: _selectedChatId, content: content));
  }

  void markAllAsRead() {
    for (var chat in joinedChats) {
      for (var message in chat.messages) {
        message.hasBeenRead = true;
      }
    }

    notifyListeners();
  }

  String _getErrorMessageLocalized(BuildContext context) {
    switch (_errorMessage) {
      case ErrorMessage.chatNotFound:
        return AppLocalizations.of(context)!.chatNotFound;
      case ErrorMessage.cannotJoinGameChat:
        return AppLocalizations.of(context)!.cannotJoinGameChat;
      case ErrorMessage.cannotLeaveGameChat:
        return AppLocalizations.of(context)!.cannotLeaveGameChat;
      case ErrorMessage.alreadyInChat:
        return AppLocalizations.of(context)!.alreadyInChat;
      case ErrorMessage.notInChat:
        return AppLocalizations.of(context)!.notInChat;
      case ErrorMessage.notChatCreator:
        return AppLocalizations.of(context)!.notChatCreator;
      case ErrorMessage.cannotJoinGeneralChat:
        return AppLocalizations.of(context)!.cannotJoinGeneralChat;
      case ErrorMessage.cannotLeaveGeneralChat:
        return AppLocalizations.of(context)!.cannotLeaveGeneralChat;
      case ErrorMessage.cannotDeleteGeneralChat:
        return AppLocalizations.of(context)!.cannotDeleteGeneralChat;
      case ErrorMessage.chatDeleted:
        return AppLocalizations.of(context)!.chatDeleted;
      case ErrorMessage.chatLeft:
        return AppLocalizations.of(context)!.chatLeft;
      default:
        return '';
    }
  }

  void showError(BuildContext context) {
    if (_errorMessage == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getErrorMessageLocalized(context),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );

    _errorMessage = null;
  }

  void _onMessage(ServerToClientMessageDto data) {
    _messageReceived(
        ClientMessage(
            data.sender,
            data.content,
            data.timestamp,
            data.senderAvatar,
            _selectedChatId == data.chatId || data.sender == username),
        data.chatId);
  }

  void _playNotificationSound() async {
    if (!Platform.isAndroid) return;

    await _player.stop();
    await _player.play(
      AssetSource(
        'audio/pristine-609.mp3',
      ),
      volume: 1,
    );
  }

  void _onChatCreated(ChatCreatedDto data) {
    if (_chats.containsKey(data.chatId)) {
      _logService.error('Chat already exists : ${data.chatId}');
      return;
    }

    _chats[data.chatId] =
        ClientChat(data.chatId, data.name, [], data.creator, false);

    notifyListeners();
  }

  void _onChatDeleted(ChatIdDto data) {
    _chats.remove(data.chatId);

    if (_selectedChatId == data.chatId) {
      _errorMessage = ErrorMessage.chatDeleted;
      unselectChat();
    }

    notifyListeners();
  }

  void _onChatJoined(ChatIdDto data) async {
    if (!_chats.containsKey(data.chatId)) {
      await _getAvailableChats();
    }
    if (!_chats.containsKey(data.chatId)) {
      _logService.error('Chat not found : ${data.chatId}');
      return;
    }

    _chats[data.chatId]!.isJoined = true;

    selectChat(data.chatId);

    notifyListeners();
  }

  void _onChatLeft(ChatIdDto data) {
    if (!_chats.containsKey(data.chatId)) {
      _logService.error('Chat not found : ${data.chatId}');
      return;
    }

    _chats[data.chatId]!.isJoined = false;

    if (_selectedChatId == data.chatId) {
      _errorMessage = ErrorMessage.chatLeft;
      unselectChat();
    }

    notifyListeners();
  }

  void _onServerMessage(ServerMessageDto data) {
    _messageReceived(
        ClientMessage('', data.content, data.timestamp, '',
            _selectedChatId == data.chatId,
            isFromServer: true, frenchContent: data.frenchContent),
        data.chatId);
  }

  void _onChatNotFound(ChatIdDto data) {
    _errorMessage = ErrorMessage.chatNotFound;
    _logService.error('Chat not found : ${data.chatId}');
    notifyListeners();
  }

  void _onCannotJoinGameChat(ChatIdDto data) {
    _errorMessage = ErrorMessage.cannotJoinGameChat;
    _logService.error('Cannot join game chat : ${data.chatId}');
    notifyListeners();
  }

  void _onCannotLeaveGameChat(ChatIdDto data) {
    _errorMessage = ErrorMessage.cannotLeaveGameChat;
    _logService.error('Cannot leave game chat : ${data.chatId}');
    notifyListeners();
  }

  void _onAlreadyInChat(ChatIdDto data) {
    _errorMessage = ErrorMessage.alreadyInChat;
    _logService.error('Already in chat : ${data.chatId}');
    notifyListeners();
  }

  void _onNotInChat(ChatIdDto data) {
    _errorMessage = ErrorMessage.notInChat;
    _logService.error('Not in chat : ${data.chatId}');
    notifyListeners();
  }

  void _onNotChatCreator(ChatIdDto data) {
    _errorMessage = ErrorMessage.notChatCreator;
    _logService.error('Not chat creator : ${data.chatId}');
    notifyListeners();
  }

  void _onCannotJoinGeneralChat() {
    _errorMessage = ErrorMessage.cannotJoinGeneralChat;
    _logService.error('Cannot join general chat');
    notifyListeners();
  }

  void _onCannotLeaveGeneralChat() {
    _errorMessage = ErrorMessage.cannotLeaveGeneralChat;
    _logService.error('Cannot leave general chat');
    notifyListeners();
  }

  void _onCannotDeleteGeneralChat() {
    _errorMessage = ErrorMessage.cannotDeleteGeneralChat;
    _logService.error('Cannot delete general chat');
    notifyListeners();
  }

  void _messageReceived(ClientMessage message, String chatId) {
    final chat = _chats[chatId];

    if (chat == null) {
      _logService.error('Chat not found : $chatId');
      return;
    }

    chat.messages.add(message);

    _logService.info('Message received : $chatId : ${message.content}');

    notifyListeners();

    if (_selectedChatId == chat.chatId && chat.isJoined) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageInSelectedChatNotifier.notifyListeners();
      });
    }

    if (message.sender != username && chat.isJoined) {
      _playNotificationSound();
    }

    if (message.sender != username &&
        !message.isFromServer &&
        chat.isJoined &&
        _appLifecycleState != AppLifecycleState.resumed) {
      final title = '${_appLocalizations.messageNotification} ${chat.name}';
      final value = '${message.sender} : ${message.content}';
      _localNotificationService.showNotificationAndroid(title, value);
    }

    if (message.isFromServer &&
        chat.isJoined &&
        _appLifecycleState != AppLifecycleState.resumed) {
      final title =
          '${_appLocalizations.serverMessageNotification} ${chat.name}';
      final value = _settingsController.locale.languageCode == 'fr'
          ? message.frenchContent
          : message.content;
      _localNotificationService.showNotificationAndroid(title, value);
    }
  }

  void _emitMessage(ClientToServerMessageDto data) {
    _socketIoService.emit(GameManagerEvent.message, {
      'chatId': data.chatId,
      'content': data.content,
    });
  }

  void _emitCreateChat(ChatNameDto data) {
    _socketIoService.emit(GameManagerEvent.createChat, {
      'name': data.name,
    });
  }

  void _emitDeleteChat(ChatIdDto data) {
    _socketIoService.emit(GameManagerEvent.deleteChat, {
      'chatId': data.chatId,
    });
  }

  void _emitJoinChat(ChatIdDto data) {
    _socketIoService.emit(GameManagerEvent.joinChat, {
      'chatId': data.chatId,
    });
  }

  void _emitLeaveChat(ChatIdDto data) {
    _socketIoService.emit(GameManagerEvent.leaveChat, {
      'chatId': data.chatId,
    });
  }

  void _listen() {
    _socketIoService.on(GameManagerEvent.message, (data) {
      _onMessage(ServerToClientMessageDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.chatCreated, (data) {
      _onChatCreated(ChatCreatedDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.chatDeleted, (data) {
      _onChatDeleted(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.chatJoined, (data) {
      _onChatJoined(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.chatLeft, (data) {
      _onChatLeft(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.serverMessage, (data) {
      _onServerMessage(ServerMessageDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.chatNotFound, (data) {
      _onChatNotFound(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.cannotJoinGameChat, (data) {
      _onCannotJoinGameChat(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.cannotLeaveGameChat, (data) {
      _onCannotLeaveGameChat(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.alreadyInChat, (data) {
      _onAlreadyInChat(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.notInChat, (data) {
      _onNotInChat(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.notChatCreator, (data) {
      _onNotChatCreator(ChatIdDto.fromJson(data));
    });

    _socketIoService.on(GameManagerEvent.cannotJoinGeneralChat, (_) {
      _onCannotJoinGeneralChat();
    });

    _socketIoService.on(GameManagerEvent.cannotLeaveGeneralChat, (_) {
      _onCannotLeaveGeneralChat();
    });

    _socketIoService.on(GameManagerEvent.cannotDeleteGeneralChat, (_) {
      _onCannotDeleteGeneralChat();
    });
  }

  Future<void> _getAvailableChats() async {
    final response = await _api.apiChatAvailableChatsGet();
    if (response.body == null) return;

    _chats.addAll({
      for (var chat
          in response.body!.where((chat) => !_chats.containsKey(chat.chatId)))
        chat.chatId: ClientChat(
          chat.chatId,
          chat.name,
          [],
          chat.creator,
          false,
        )
    });
    notifyListeners();
  }

  Future<void> _getJoinedChats() async {
    final response = await _api.apiChatJoinedChatsGet();
    if (response.body == null) return;

    for (final chatId in response.body!) {
      final chat = _chats[chatId.chatId];
      if (chat == null) {
        _logService.error('Chat not found : $chatId');
        continue;
      }

      chat.isJoined = true;
    }
  }

  _getGeneralChatId() async {
    final response = await _api.apiChatGeneralChatIdGet();
    if (response.body == null) return;

    _generalChatId = response.body!.chatId;
    notifyListeners();
  }
}
