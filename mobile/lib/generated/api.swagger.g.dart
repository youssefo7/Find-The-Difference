// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameTemplate _$GameTemplateFromJson(Map<String, dynamic> json) => GameTemplate(
      id: json['_id'] as String,
      name: json['name'] as String,
      deleted: json['deleted'] as bool,
      difficulty: gameTemplateDifficultyFromJson(json['difficulty']),
      firstImage: json['firstImage'] as String,
      secondImage: json['secondImage'] as String,
      price: (json['price'] as num).toDouble(),
      creator: json['creator'] as String,
      nGroups: (json['nGroups'] as num).toDouble(),
    );

Map<String, dynamic> _$GameTemplateToJson(GameTemplate instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'deleted': instance.deleted,
      'difficulty': gameTemplateDifficultyToJson(instance.difficulty),
      'firstImage': instance.firstImage,
      'secondImage': instance.secondImage,
      'price': instance.price,
      'creator': instance.creator,
      'nGroups': instance.nGroups,
    };

ServerCreateGameDto _$ServerCreateGameDtoFromJson(Map<String, dynamic> json) =>
    ServerCreateGameDto(
      name: json['name'] as String,
      firstImage: json['firstImage'] as String,
      secondImage: json['secondImage'] as String,
      radius: (json['radius'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ServerCreateGameDtoToJson(
        ServerCreateGameDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'firstImage': instance.firstImage,
      'secondImage': instance.secondImage,
      'radius': instance.radius,
      'price': instance.price,
    };

ErrorResponseDto _$ErrorResponseDtoFromJson(Map<String, dynamic> json) =>
    ErrorResponseDto(
      statusCode: (json['statusCode'] as num).toDouble(),
      message: errorResponseDtoMessageFromJson(json['message']),
      error: json['error'] as String,
    );

Map<String, dynamic> _$ErrorResponseDtoToJson(ErrorResponseDto instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': errorResponseDtoMessageToJson(instance.message),
      'error': instance.error,
    };

CreateImagesDifferencesDto _$CreateImagesDifferencesDtoFromJson(
        Map<String, dynamic> json) =>
    CreateImagesDifferencesDto(
      image1Base64: json['image1Base64'] as String,
      image2Base64: json['image2Base64'] as String,
      radius: (json['radius'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateImagesDifferencesDtoToJson(
        CreateImagesDifferencesDto instance) =>
    <String, dynamic>{
      'image1Base64': instance.image1Base64,
      'image2Base64': instance.image2Base64,
      'radius': instance.radius,
    };

ServerCreateDiffResult _$ServerCreateDiffResultFromJson(
        Map<String, dynamic> json) =>
    ServerCreateDiffResult(
      nGroups: (json['nGroups'] as num).toDouble(),
      difficulty: serverCreateDiffResultDifficultyFromJson(json['difficulty']),
      diffImage: json['diffImage'] as String,
    );

Map<String, dynamic> _$ServerCreateDiffResultToJson(
        ServerCreateDiffResult instance) =>
    <String, dynamic>{
      'nGroups': instance.nGroups,
      'difficulty': serverCreateDiffResultDifficultyToJson(instance.difficulty),
      'diffImage': instance.diffImage,
    };

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

JwtTokenDto _$JwtTokenDtoFromJson(Map<String, dynamic> json) => JwtTokenDto(
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$JwtTokenDtoToJson(JwtTokenDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
    };

CreateUserDto _$CreateUserDtoFromJson(Map<String, dynamic> json) =>
    CreateUserDto(
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$CreateUserDtoToJson(CreateUserDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'password': instance.password,
    };

ChangePasswordDto _$ChangePasswordDtoFromJson(Map<String, dynamic> json) =>
    ChangePasswordDto(
      password: json['password'] as String,
    );

Map<String, dynamic> _$ChangePasswordDtoToJson(ChangePasswordDto instance) =>
    <String, dynamic>{
      'password': instance.password,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      avatarUrl: json['avatarUrl'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'avatarUrl': instance.avatarUrl,
      'username': instance.username,
    };

Theme _$ThemeFromJson(Map<String, dynamic> json) => Theme(
      primaryColor: json['primaryColor'] as String,
    );

Map<String, dynamic> _$ThemeToJson(Theme instance) => <String, dynamic>{
      'primaryColor': instance.primaryColor,
    };

DifferenceFoundRatioDto _$DifferenceFoundRatioDtoFromJson(
        Map<String, dynamic> json) =>
    DifferenceFoundRatioDto(
      differenceFound: (json['differenceFound'] as num).toDouble(),
    );

Map<String, dynamic> _$DifferenceFoundRatioDtoToJson(
        DifferenceFoundRatioDto instance) =>
    <String, dynamic>{
      'differenceFound': instance.differenceFound,
    };

ReplayEvent _$ReplayEventFromJson(Map<String, dynamic> json) => ReplayEvent(
      name: json['name'] as String,
      time: (json['time'] as num).toDouble(),
      data: json['data'] as Object,
    );

Map<String, dynamic> _$ReplayEventToJson(ReplayEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'time': instance.time,
      'data': instance.data,
    };

ReceiveReplayDto _$ReceiveReplayDtoFromJson(Map<String, dynamic> json) =>
    ReceiveReplayDto(
      id: json['id'] as String,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ReplayEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gameTemplateId: json['gameTemplateId'] as String,
      gameMode: receiveReplayDtoGameModeFromJson(json['gameMode']),
      username: json['username'] as String,
    );

Map<String, dynamic> _$ReceiveReplayDtoToJson(ReceiveReplayDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'gameTemplateId': instance.gameTemplateId,
      'gameMode': receiveReplayDtoGameModeToJson(instance.gameMode),
      'username': instance.username,
    };

SendReplayDto _$SendReplayDtoFromJson(Map<String, dynamic> json) =>
    SendReplayDto(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ReplayEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gameTemplateId: json['gameTemplateId'] as String,
      gameMode: sendReplayDtoGameModeFromJson(json['gameMode']),
    );

Map<String, dynamic> _$SendReplayDtoToJson(SendReplayDto instance) =>
    <String, dynamic>{
      'events': instance.events.map((e) => e.toJson()).toList(),
      'gameTemplateId': instance.gameTemplateId,
      'gameMode': sendReplayDtoGameModeToJson(instance.gameMode),
    };

LocaleDto _$LocaleDtoFromJson(Map<String, dynamic> json) => LocaleDto(
      locale: json['locale'] as String,
    );

Map<String, dynamic> _$LocaleDtoToJson(LocaleDto instance) => <String, dynamic>{
      'locale': instance.locale,
    };

UsernameDto _$UsernameDtoFromJson(Map<String, dynamic> json) => UsernameDto(
      username: json['username'] as String,
    );

Map<String, dynamic> _$UsernameDtoToJson(UsernameDto instance) =>
    <String, dynamic>{
      'username': instance.username,
    };

ChangeAvatarDto _$ChangeAvatarDtoFromJson(Map<String, dynamic> json) =>
    ChangeAvatarDto(
      avatarUrl: json['avatarUrl'] as String,
    );

Map<String, dynamic> _$ChangeAvatarDtoToJson(ChangeAvatarDto instance) =>
    <String, dynamic>{
      'avatarUrl': instance.avatarUrl,
    };

History _$HistoryFromJson(Map<String, dynamic> json) => History(
      startTime: (json['startTime'] as num).toDouble(),
      totalTime: (json['totalTime'] as num).toDouble(),
      gameMode: historyGameModeFromJson(json['gameMode']),
      winners: (json['winners'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      losers: (json['losers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      quitters: (json['quitters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'startTime': instance.startTime,
      'totalTime': instance.totalTime,
      'gameMode': historyGameModeToJson(instance.gameMode),
      'winners': instance.winners,
      'losers': instance.losers,
      'quitters': instance.quitters,
    };

ChatSchema _$ChatSchemaFromJson(Map<String, dynamic> json) => ChatSchema(
      chatId: json['chatId'] as String,
      name: json['name'] as String,
      creator: json['creator'] as String,
    );

Map<String, dynamic> _$ChatSchemaToJson(ChatSchema instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'name': instance.name,
      'creator': instance.creator,
    };

ChatIdSchema _$ChatIdSchemaFromJson(Map<String, dynamic> json) => ChatIdSchema(
      chatId: json['chatId'] as String,
    );

Map<String, dynamic> _$ChatIdSchemaToJson(ChatIdSchema instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
    };

AccountHistory _$AccountHistoryFromJson(Map<String, dynamic> json) =>
    AccountHistory(
      username: json['username'] as String,
      action: json['action'] as String,
      timestamp: (json['timestamp'] as num).toDouble(),
    );

Map<String, dynamic> _$AccountHistoryToJson(AccountHistory instance) =>
    <String, dynamic>{
      'username': instance.username,
      'action': instance.action,
      'timestamp': instance.timestamp,
    };

BuyGameDto _$BuyGameDtoFromJson(Map<String, dynamic> json) => BuyGameDto(
      gameTemplateId: json['gameTemplateId'] as String,
    );

Map<String, dynamic> _$BuyGameDtoToJson(BuyGameDto instance) =>
    <String, dynamic>{
      'gameTemplateId': instance.gameTemplateId,
    };
