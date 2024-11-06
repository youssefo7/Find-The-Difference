// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_io_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      senderAvatar: json['senderAvatar'] as String,
      isStickerGif: json['isStickerGif'] as bool?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'sender': instance.sender,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'senderAvatar': instance.senderAvatar,
      'isStickerGif': instance.isStickerGif,
    };

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      creator: json['creator'] as String,
      name: json['name'] as String,
      isInGame: json['isInGame'] as bool,
      chatId: json['chatId'] as String,
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'users': instance.users,
      'creator': instance.creator,
      'name': instance.name,
      'isInGame': instance.isInGame,
      'chatId': instance.chatId,
    };

ChatIdDto _$ChatIdDtoFromJson(Map<String, dynamic> json) => ChatIdDto(
      chatId: json['chatId'] as String,
    );

Map<String, dynamic> _$ChatIdDtoToJson(ChatIdDto instance) => <String, dynamic>{
      'chatId': instance.chatId,
    };

ChatNameDto _$ChatNameDtoFromJson(Map<String, dynamic> json) => ChatNameDto(
      name: json['name'] as String,
    );

Map<String, dynamic> _$ChatNameDtoToJson(ChatNameDto instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

ChatCreatorDto _$ChatCreatorDtoFromJson(Map<String, dynamic> json) =>
    ChatCreatorDto(
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$ChatCreatorDtoToJson(ChatCreatorDto instance) =>
    <String, dynamic>{
      'creator': instance.creator,
    };

ClientToServerMessageDto _$ClientToServerMessageDtoFromJson(
        Map<String, dynamic> json) =>
    ClientToServerMessageDto(
      chatId: json['chatId'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ClientToServerMessageDtoToJson(
        ClientToServerMessageDto instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'content': instance.content,
    };

ServerToClientMessageDto _$ServerToClientMessageDtoFromJson(
        Map<String, dynamic> json) =>
    ServerToClientMessageDto(
      chatId: json['chatId'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      senderAvatar: json['senderAvatar'] as String,
    );

Map<String, dynamic> _$ServerToClientMessageDtoToJson(
        ServerToClientMessageDto instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'sender': instance.sender,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'senderAvatar': instance.senderAvatar,
    };

ChatCreatedDto _$ChatCreatedDtoFromJson(Map<String, dynamic> json) =>
    ChatCreatedDto(
      chatId: json['chatId'] as String,
      name: json['name'] as String,
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$ChatCreatedDtoToJson(ChatCreatedDto instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'name': instance.name,
      'creator': instance.creator,
    };

ServerMessageDto _$ServerMessageDtoFromJson(Map<String, dynamic> json) =>
    ServerMessageDto(
      chatId: json['chatId'] as String,
      content: json['content'] as String,
      frenchContent: json['frenchContent'] as String,
      timestamp: json['timestamp'] as int,
    );

Map<String, dynamic> _$ServerMessageDtoToJson(ServerMessageDto instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'content': instance.content,
      'frenchContent': instance.frenchContent,
      'timestamp': instance.timestamp,
    };

IdentifyDifferenceDto _$IdentifyDifferenceDtoFromJson(
        Map<String, dynamic> json) =>
    IdentifyDifferenceDto(
      position: Vec2.fromJson(json['position'] as Map<String, dynamic>),
      imageClicked: $enumDecode(_$ImageClickedEnumMap, json['imageClicked']),
    );

Map<String, dynamic> _$IdentifyDifferenceDtoToJson(
        IdentifyDifferenceDto instance) =>
    <String, dynamic>{
      'position': instance.position,
      'imageClicked': _$ImageClickedEnumMap[instance.imageClicked],
    };

const _$ImageClickedEnumMap = {
  ImageClicked.swaggerGeneratedUnknown: null,
  ImageClicked.left: 'left',
  ImageClicked.right: 'right',
};

StartGameDto _$StartGameDtoFromJson(Map<String, dynamic> json) => StartGameDto(
      nGroups: json['nGroups'] as int,
      teams: (json['teams'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k),
            (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      timeConfig:
          TimeConfigDto.fromJson(json['timeConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StartGameDtoToJson(StartGameDto instance) =>
    <String, dynamic>{
      'nGroups': instance.nGroups,
      'teams': instance.teams.map((k, e) => MapEntry(k.toString(), e)),
      'timeConfig': instance.timeConfig,
    };

EndGameDto _$EndGameDtoFromJson(Map<String, dynamic> json) => EndGameDto(
      winners:
          (json['winners'] as List<dynamic>).map((e) => e as String).toList(),
      losers:
          (json['losers'] as List<dynamic>).map((e) => e as String).toList(),
      totalTimeMs: json['totalTimeMs'] as int,
      pointsReceived: json['pointsReceived'] as int,
    );

Map<String, dynamic> _$EndGameDtoToJson(EndGameDto instance) =>
    <String, dynamic>{
      'winners': instance.winners,
      'losers': instance.losers,
      'totalTimeMs': instance.totalTimeMs,
      'pointsReceived': instance.pointsReceived,
    };

DifferenceFoundDto _$DifferenceFoundDtoFromJson(Map<String, dynamic> json) =>
    DifferenceFoundDto(
      username: json['username'] as String,
      time: json['time'] as int,
    );

Map<String, dynamic> _$DifferenceFoundDtoToJson(DifferenceFoundDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'time': instance.time,
    };

DifferenceNotFoundDto _$DifferenceNotFoundDtoFromJson(
        Map<String, dynamic> json) =>
    DifferenceNotFoundDto(
      username: json['username'] as String,
      time: json['time'] as int,
    );

Map<String, dynamic> _$DifferenceNotFoundDtoToJson(
        DifferenceNotFoundDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'time': instance.time,
    };

ShowErrorDto _$ShowErrorDtoFromJson(Map<String, dynamic> json) => ShowErrorDto(
      position: Vec2.fromJson(json['position'] as Map<String, dynamic>),
      imageClicked: $enumDecode(_$ImageClickedEnumMap, json['imageClicked']),
    );

Map<String, dynamic> _$ShowErrorDtoToJson(ShowErrorDto instance) =>
    <String, dynamic>{
      'position': instance.position,
      'imageClicked': _$ImageClickedEnumMap[instance.imageClicked],
    };

RemovePixelsDto _$RemovePixelsDtoFromJson(Map<String, dynamic> json) =>
    RemovePixelsDto(
      pixels: (json['pixels'] as List<dynamic>)
          .map((e) => Vec2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RemovePixelsDtoToJson(RemovePixelsDto instance) =>
    <String, dynamic>{
      'pixels': instance.pixels,
    };

TimeEventDto _$TimeEventDtoFromJson(Map<String, dynamic> json) => TimeEventDto(
      timeMs: json['timeMs'] as int,
      team2TimeMs: json['team2TimeMs'] as int?,
    );

Map<String, dynamic> _$TimeEventDtoToJson(TimeEventDto instance) =>
    <String, dynamic>{
      'timeMs': instance.timeMs,
      'team2TimeMs': instance.team2TimeMs,
    };

ReceiveChatMessageDto _$ReceiveChatMessageDtoFromJson(
        Map<String, dynamic> json) =>
    ReceiveChatMessageDto(
      message: json['message'] as String,
      sender: json['sender'] as String,
      time: json['time'] as int,
    );

Map<String, dynamic> _$ReceiveChatMessageDtoToJson(
        ReceiveChatMessageDto instance) =>
    <String, dynamic>{
      'message': instance.message,
      'sender': instance.sender,
      'time': instance.time,
    };

CheatModeDto _$CheatModeDtoFromJson(Map<String, dynamic> json) => CheatModeDto(
      groupToPixels: (json['groupToPixels'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => Vec2.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$CheatModeDtoToJson(CheatModeDto instance) =>
    <String, dynamic>{
      'groupToPixels': instance.groupToPixels,
    };

ChangeTemplateDto _$ChangeTemplateDtoFromJson(Map<String, dynamic> json) =>
    ChangeTemplateDto(
      nextGameTemplateId: json['nextGameTemplateId'] as String?,
      pixelsToRemove: (json['pixelsToRemove'] as List<dynamic>?)
          ?.map((e) => Vec2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChangeTemplateDtoToJson(ChangeTemplateDto instance) =>
    <String, dynamic>{
      'nextGameTemplateId': instance.nextGameTemplateId,
      'pixelsToRemove': instance.pixelsToRemove,
    };

SendChatMessageDto _$SendChatMessageDtoFromJson(Map<String, dynamic> json) =>
    SendChatMessageDto(
      message: json['message'] as String,
    );

Map<String, dynamic> _$SendChatMessageDtoToJson(SendChatMessageDto instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

ReceiveHintDto _$ReceiveHintDtoFromJson(Map<String, dynamic> json) =>
    ReceiveHintDto(
      rect: (json['rect'] as List<dynamic>)
          .map((e) => Vec2.fromJson(e as Map<String, dynamic>))
          .toList(),
      sender: json['sender'] as String,
    );

Map<String, dynamic> _$ReceiveHintDtoToJson(ReceiveHintDto instance) =>
    <String, dynamic>{
      'rect': instance.rect,
      'sender': instance.sender,
    };

SendHintDto _$SendHintDtoFromJson(Map<String, dynamic> json) => SendHintDto(
      rect: (json['rect'] as List<dynamic>)
          .map((e) => Vec2.fromJson(e as Map<String, dynamic>))
          .toList(),
      player: json['player'] as String?,
    );

Map<String, dynamic> _$SendHintDtoToJson(SendHintDto instance) =>
    <String, dynamic>{
      'rect': instance.rect,
      'player': instance.player,
    };

StateDto _$StateDtoFromJson(Map<String, dynamic> json) => StateDto(
      startGameDto:
          StartGameDto.fromJson(json['startGameDto'] as Map<String, dynamic>),
      pixelToRemove: (json['pixelToRemove'] as List<dynamic>)
          .map((e) => Vec2.fromJson(e as Map<String, dynamic>))
          .toList(),
      playerScore: Map<String, int>.from(json['playerScore'] as Map),
      observers:
          (json['observers'] as List<dynamic>).map((e) => e as String).toList(),
      timeLimitPreload: (json['timeLimitPreload'] as List<dynamic>?)
          ?.map((e) => ChangeTemplateDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StateDtoToJson(StateDto instance) => <String, dynamic>{
      'startGameDto': instance.startGameDto,
      'pixelToRemove': instance.pixelToRemove,
      'playerScore': instance.playerScore,
      'observers': instance.observers,
      'timeLimitPreload': instance.timeLimitPreload,
    };

UpdateBalanceDto _$UpdateBalanceDtoFromJson(Map<String, dynamic> json) =>
    UpdateBalanceDto(
      balance: json['balance'] as int,
    );

Map<String, dynamic> _$UpdateBalanceDtoToJson(UpdateBalanceDto instance) =>
    <String, dynamic>{
      'balance': instance.balance,
    };

WaitingGamesListDto _$WaitingGamesListDtoFromJson(Map<String, dynamic> json) =>
    WaitingGamesListDto(
      waitingGames: (json['waitingGames'] as List<dynamic>)
          .map((e) => WaitingGameDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      observerGames: (json['observerGames'] as List<dynamic>)
          .map((e) => ObserverGameDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WaitingGamesListDtoToJson(
        WaitingGamesListDto instance) =>
    <String, dynamic>{
      'waitingGames': instance.waitingGames,
      'observerGames': instance.observerGames,
    };

WaitingGameDto _$WaitingGameDtoFromJson(Map<String, dynamic> json) =>
    WaitingGameDto(
      templateId: json['templateId'] as String,
      instanceId: json['instanceId'] as String,
      creator: json['creator'] as String,
      gameMode: $enumDecode(_$HistoryGameModeEnumMap, json['gameMode']),
      players:
          (json['players'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$WaitingGameDtoToJson(WaitingGameDto instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'instanceId': instance.instanceId,
      'creator': instance.creator,
      'gameMode': _$HistoryGameModeEnumMap[instance.gameMode],
      'players': instance.players,
    };

const _$HistoryGameModeEnumMap = {
  HistoryGameMode.swaggerGeneratedUnknown: null,
  HistoryGameMode.teamclassic: 'teamClassic',
  HistoryGameMode.timelimitsinglediff: 'timeLimitSingleDiff',
  HistoryGameMode.timelimitaugmented: 'timeLimitAugmented',
  HistoryGameMode.timelimitturnbyturn: 'timeLimitTurnByTurn',
  HistoryGameMode.classicmultiplayer: 'classicMultiplayer',
};

ObserverGameDto _$ObserverGameDtoFromJson(Map<String, dynamic> json) =>
    ObserverGameDto(
      templateId: json['templateId'] as String,
      instanceId: json['instanceId'] as String,
      players:
          (json['players'] as List<dynamic>).map((e) => e as String).toList(),
      gameMode: $enumDecode(_$HistoryGameModeEnumMap, json['gameMode']),
      hasObservers: json['hasObservers'] as bool,
    );

Map<String, dynamic> _$ObserverGameDtoToJson(ObserverGameDto instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'instanceId': instance.instanceId,
      'players': instance.players,
      'gameMode': _$HistoryGameModeEnumMap[instance.gameMode],
      'hasObservers': instance.hasObservers,
    };

JoinGameDto _$JoinGameDtoFromJson(Map<String, dynamic> json) => JoinGameDto(
      instanceId: json['instanceId'] as String,
    );

Map<String, dynamic> _$JoinGameDtoToJson(JoinGameDto instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
    };

JoinRequestsDto _$JoinRequestsDtoFromJson(Map<String, dynamic> json) =>
    JoinRequestsDto(
      requests:
          (json['requests'] as List<dynamic>).map((e) => e as String).toList(),
      players:
          (json['players'] as List<dynamic>).map((e) => e as String).toList(),
      teams: (json['teams'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
    );

Map<String, dynamic> _$JoinRequestsDtoToJson(JoinRequestsDto instance) =>
    <String, dynamic>{
      'requests': instance.requests,
      'players': instance.players,
      'teams': instance.teams,
    };

TimeConfigDto _$TimeConfigDtoFromJson(Map<String, dynamic> json) =>
    TimeConfigDto(
      totalTime: json['totalTime'] as int,
      rewardTime: json['rewardTime'] as int,
      cheatModeAllowed: json['cheatModeAllowed'] as bool,
    );

Map<String, dynamic> _$TimeConfigDtoToJson(TimeConfigDto instance) =>
    <String, dynamic>{
      'totalTime': instance.totalTime,
      'rewardTime': instance.rewardTime,
      'cheatModeAllowed': instance.cheatModeAllowed,
    };

InstantiateGameDto _$InstantiateGameDtoFromJson(Map<String, dynamic> json) =>
    InstantiateGameDto(
      gameTemplateId: json['gameTemplateId'] as String,
      gameMode: $enumDecode(_$HistoryGameModeEnumMap, json['gameMode']),
      timeConfig:
          TimeConfigDto.fromJson(json['timeConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InstantiateGameDtoToJson(InstantiateGameDto instance) =>
    <String, dynamic>{
      'gameTemplateId': instance.gameTemplateId,
      'gameMode': _$HistoryGameModeEnumMap[instance.gameMode],
      'timeConfig': instance.timeConfig,
    };

ChangeTeamDto _$ChangeTeamDtoFromJson(Map<String, dynamic> json) =>
    ChangeTeamDto(
      newTeam: json['newTeam'] as int,
    );

Map<String, dynamic> _$ChangeTeamDtoToJson(ChangeTeamDto instance) =>
    <String, dynamic>{
      'newTeam': instance.newTeam,
    };
