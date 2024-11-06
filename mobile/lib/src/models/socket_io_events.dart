import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/generated/api.enums.swagger.dart';
import 'package:mobile/src/models/game_template.dart';
import 'package:mobile/src/models/typedef.dart';

part 'socket_io_events.g.dart';

@JsonSerializable()
class Message {
  final Username sender;
  final String content;
  final UnixTimeMs timestamp;
  final String senderAvatar;
  final bool? isStickerGif;

  Message(
      {required this.sender,
      required this.content,
      required this.timestamp,
      required this.senderAvatar,
      required this.isStickerGif});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Chat {
  final List<Username> users;
  final Username creator;
  final String name;
  final bool isInGame;
  final ChatId chatId;

  Chat(
      {required this.users,
      required this.creator,
      required this.name,
      required this.isInGame,
      required this.chatId});

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);
}

@JsonSerializable()
class ChatIdDto {
  final ChatId chatId;

  ChatIdDto({required this.chatId});

  factory ChatIdDto.fromJson(Map<String, dynamic> json) =>
      _$ChatIdDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatIdDtoToJson(this);
}

@JsonSerializable()
class ChatNameDto {
  final String name;

  ChatNameDto({required this.name});

  factory ChatNameDto.fromJson(Map<String, dynamic> json) =>
      _$ChatNameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatNameDtoToJson(this);
}

@JsonSerializable()
class ChatCreatorDto {
  final Username creator;

  ChatCreatorDto({required this.creator});

  factory ChatCreatorDto.fromJson(Map<String, dynamic> json) =>
      _$ChatCreatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCreatorDtoToJson(this);
}

@JsonSerializable()
class ClientToServerMessageDto {
  final String chatId;
  final String content;

  ClientToServerMessageDto({required this.chatId, required this.content});

  factory ClientToServerMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ClientToServerMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClientToServerMessageDtoToJson(this);
}

@JsonSerializable()
class ServerToClientMessageDto {
  final ChatId chatId;
  final Username sender;
  final String content;
  final UnixTimeMs timestamp;
  final String senderAvatar;

  ServerToClientMessageDto(
      {required this.chatId,
      required this.sender,
      required this.content,
      required this.timestamp,
      required this.senderAvatar});

  factory ServerToClientMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ServerToClientMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerToClientMessageDtoToJson(this);
}

@JsonSerializable()
class ChatCreatedDto {
  final ChatId chatId;
  final String name;
  final Username creator;

  ChatCreatedDto(
      {required this.chatId, required this.name, required this.creator});

  factory ChatCreatedDto.fromJson(Map<String, dynamic> json) =>
      _$ChatCreatedDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCreatedDtoToJson(this);
}

@JsonSerializable()
class ServerMessageDto {
  final ChatId chatId;
  final String content;
  final String frenchContent;
  final UnixTimeMs timestamp;

  ServerMessageDto(
      {required this.chatId,
      required this.content,
      required this.frenchContent,
      required this.timestamp});

  factory ServerMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ServerMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerMessageDtoToJson(this);
}

@JsonSerializable()
class IdentifyDifferenceDto {
  final Vec2 position;
  final ImageClicked imageClicked;

  IdentifyDifferenceDto({required this.position, required this.imageClicked});

  factory IdentifyDifferenceDto.fromJson(Map<String, dynamic> json) =>
      _$IdentifyDifferenceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IdentifyDifferenceDtoToJson(this);
}

@JsonSerializable()
class StartGameDto {
  final int nGroups;
  final Map<TeamIndex, List<Username>> teams;
  final TimeConfigDto timeConfig;

  StartGameDto(
      {required this.nGroups, required this.teams, required this.timeConfig});

  factory StartGameDto.fromJson(Map<String, dynamic> json) =>
      _$StartGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StartGameDtoToJson(this);
}

@JsonSerializable()
class EndGameDto {
  final List<Username> winners;
  final List<Username> losers;
  final int totalTimeMs;
  final int pointsReceived;

  EndGameDto(
      {required this.winners,
      required this.losers,
      required this.totalTimeMs,
      required this.pointsReceived});

  factory EndGameDto.fromJson(Map<String, dynamic> json) =>
      _$EndGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EndGameDtoToJson(this);
}

@JsonSerializable()
class DifferenceFoundDto {
  final Username username;
  final UnixTimeMs time;

  DifferenceFoundDto({required this.username, required this.time});

  factory DifferenceFoundDto.fromJson(Map<String, dynamic> json) =>
      _$DifferenceFoundDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DifferenceFoundDtoToJson(this);
}

@JsonSerializable()
class DifferenceNotFoundDto {
  final Username username;
  final UnixTimeMs time;

  DifferenceNotFoundDto({required this.username, required this.time});

  factory DifferenceNotFoundDto.fromJson(Map<String, dynamic> json) =>
      _$DifferenceNotFoundDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DifferenceNotFoundDtoToJson(this);
}

@JsonSerializable()
class ShowErrorDto {
  final Vec2 position;
  final ImageClicked imageClicked;

  ShowErrorDto({required this.position, required this.imageClicked});

  factory ShowErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ShowErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ShowErrorDtoToJson(this);
}

@JsonSerializable()
class RemovePixelsDto {
  final List<Vec2> pixels;

  RemovePixelsDto({required this.pixels});

  factory RemovePixelsDto.fromJson(Map<String, dynamic> json) =>
      _$RemovePixelsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RemovePixelsDtoToJson(this);
}

@JsonSerializable()
class TimeEventDto {
  final int timeMs;
  final int? team2TimeMs;

  TimeEventDto({required this.timeMs, required this.team2TimeMs});

  factory TimeEventDto.fromJson(Map<String, dynamic> json) =>
      _$TimeEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimeEventDtoToJson(this);
}

@JsonSerializable()
class ReceiveChatMessageDto {
  final String message;
  final Username sender;
  final UnixTimeMs time;

  ReceiveChatMessageDto(
      {required this.message, required this.sender, required this.time});

  factory ReceiveChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ReceiveChatMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiveChatMessageDtoToJson(this);
}

@JsonSerializable()
class CheatModeDto {
  final List<List<Vec2>> groupToPixels;

  CheatModeDto({required this.groupToPixels});

  factory CheatModeDto.fromJson(Map<String, dynamic> json) =>
      _$CheatModeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheatModeDtoToJson(this);
}

@JsonSerializable()
class ChangeTemplateDto {
  final GameTemplateId? nextGameTemplateId;
  final List<Vec2>? pixelsToRemove;

  ChangeTemplateDto(
      {required this.nextGameTemplateId, required this.pixelsToRemove});

  factory ChangeTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeTemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeTemplateDtoToJson(this);
}

@JsonSerializable()
class SendChatMessageDto {
  final String message;

  SendChatMessageDto({required this.message});

  factory SendChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$SendChatMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendChatMessageDtoToJson(this);
}

@JsonSerializable()
class ReceiveHintDto {
  final List<Vec2> rect;
  final Username sender;

  ReceiveHintDto({required this.rect, required this.sender});

  factory ReceiveHintDto.fromJson(Map<String, dynamic> json) =>
      _$ReceiveHintDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiveHintDtoToJson(this);
}

@JsonSerializable()
class SendHintDto {
  final List<Vec2> rect;
  final Username? player;

  SendHintDto({required this.rect, required this.player});

  factory SendHintDto.fromJson(Map<String, dynamic> json) =>
      _$SendHintDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendHintDtoToJson(this);
}

@JsonSerializable()
class StateDto {
  final StartGameDto startGameDto;
  final List<Vec2> pixelToRemove;
  final Map<Username, int> playerScore;
  final List<Username> observers;
  final List<ChangeTemplateDto>? timeLimitPreload;

  StateDto(
      {required this.startGameDto,
      required this.pixelToRemove,
      required this.playerScore,
      required this.observers,
      required this.timeLimitPreload});

  factory StateDto.fromJson(Map<String, dynamic> json) =>
      _$StateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StateDtoToJson(this);
}

@JsonSerializable()
class UpdateBalanceDto {
  final int balance;

  UpdateBalanceDto({required this.balance});

  factory UpdateBalanceDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBalanceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBalanceDtoToJson(this);
}

@JsonSerializable()
class WaitingGamesListDto {
  final List<WaitingGameDto> waitingGames;
  final List<ObserverGameDto> observerGames;

  WaitingGamesListDto(
      {required this.waitingGames, required this.observerGames});

  factory WaitingGamesListDto.fromJson(Map<String, dynamic> json) =>
      _$WaitingGamesListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WaitingGamesListDtoToJson(this);
}

@JsonSerializable()
class WaitingGameDto {
  final GameTemplateId templateId;
  final InstanceId instanceId;
  final Username creator;
  final HistoryGameMode gameMode;
  final List<Username> players;

  WaitingGameDto(
      {required this.templateId,
      required this.instanceId,
      required this.creator,
      required this.gameMode,
      required this.players});

  factory WaitingGameDto.fromJson(Map<String, dynamic> json) =>
      _$WaitingGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WaitingGameDtoToJson(this);
}

@JsonSerializable()
class ObserverGameDto {
  final GameTemplateId templateId;
  final InstanceId instanceId;
  final List<Username> players;
  final HistoryGameMode gameMode;
  final bool hasObservers;

  ObserverGameDto(
      {required this.templateId,
      required this.instanceId,
      required this.players,
      required this.gameMode,
      required this.hasObservers});

  factory ObserverGameDto.fromJson(Map<String, dynamic> json) =>
      _$ObserverGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ObserverGameDtoToJson(this);
}

@JsonSerializable()
class JoinGameDto {
  final InstanceId instanceId;

  JoinGameDto({required this.instanceId});

  factory JoinGameDto.fromJson(Map<String, dynamic> json) =>
      _$JoinGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinGameDtoToJson(this);
}

@JsonSerializable()
class JoinRequestsDto {
  final List<Username> requests;
  final List<Username> players;
  final List<List<Username>> teams;

  JoinRequestsDto(
      {required this.requests, required this.players, required this.teams});

  factory JoinRequestsDto.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinRequestsDtoToJson(this);
}

@JsonSerializable()
class TimeConfigDto {
  final int totalTime;
  final int rewardTime;
  final bool cheatModeAllowed;

  TimeConfigDto(
      {required this.totalTime,
      required this.rewardTime,
      required this.cheatModeAllowed});

  factory TimeConfigDto.fromJson(Map<String, dynamic> json) =>
      _$TimeConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimeConfigDtoToJson(this);
}

@JsonSerializable()
class InstantiateGameDto {
  final GameTemplateId gameTemplateId;
  final HistoryGameMode gameMode;
  final TimeConfigDto timeConfig;

  InstantiateGameDto(
      {required this.gameTemplateId,
      required this.gameMode,
      required this.timeConfig});

  factory InstantiateGameDto.fromJson(Map<String, dynamic> json) =>
      _$InstantiateGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InstantiateGameDtoToJson(this);
}

@JsonSerializable()
class ChangeTeamDto {
  final TeamIndex newTeam;

  ChangeTeamDto({required this.newTeam});

  factory ChangeTeamDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeTeamDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeTeamDtoToJson(this);
}
