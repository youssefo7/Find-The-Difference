// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'api.enums.swagger.dart' as enums;
export 'api.enums.swagger.dart';

part 'api.swagger.chopper.dart';
part 'api.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Api extends ChopperService {
  static Api create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    Iterable<dynamic>? interceptors,
  }) {
    if (client != null) {
      return _$Api(client);
    }

    final newClient = ChopperClient(
        services: [_$Api()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://'));
    return _$Api(newClient);
  }

  ///
  Future<chopper.Response<List<GameTemplate>>> apiGameTemplateGet() {
    generatedMapping.putIfAbsent(
        GameTemplate, () => GameTemplate.fromJsonFactory);

    return _apiGameTemplateGet();
  }

  ///
  @Get(path: '/api/game-template')
  Future<chopper.Response<List<GameTemplate>>> _apiGameTemplateGet();

  ///
  Future<chopper.Response> apiGameTemplatePost(
      {required ServerCreateGameDto? body}) {
    return _apiGameTemplatePost(body: body);
  }

  ///
  @Post(
    path: '/api/game-template',
    optionalBody: true,
  )
  Future<chopper.Response> _apiGameTemplatePost(
      {@Body() required ServerCreateGameDto? body});

  ///
  Future<chopper.Response> apiGameTemplateDelete() {
    return _apiGameTemplateDelete();
  }

  ///
  @Delete(path: '/api/game-template')
  Future<chopper.Response> _apiGameTemplateDelete();

  ///Get the number of game templates that exist
  Future<chopper.Response<num>> apiGameTemplateLengthGet() {
    return _apiGameTemplateLengthGet();
  }

  ///Get the number of game templates that exist
  @Get(path: '/api/game-template/length')
  Future<chopper.Response<num>> _apiGameTemplateLengthGet();

  ///
  ///@param id
  Future<chopper.Response<GameTemplate>> apiGameTemplateIdGet(
      {required String? id}) {
    generatedMapping.putIfAbsent(
        GameTemplate, () => GameTemplate.fromJsonFactory);

    return _apiGameTemplateIdGet(id: id);
  }

  ///
  ///@param id
  @Get(path: '/api/game-template/{id}')
  Future<chopper.Response<GameTemplate>> _apiGameTemplateIdGet(
      {@Path('id') required String? id});

  ///
  ///@param id
  Future<chopper.Response> apiGameTemplateIdDelete({required String? id}) {
    return _apiGameTemplateIdDelete(id: id);
  }

  ///
  ///@param id
  @Delete(path: '/api/game-template/{id}')
  Future<chopper.Response> _apiGameTemplateIdDelete(
      {@Path('id') required String? id});

  ///
  ///@param page
  Future<chopper.Response<List<GameTemplate>>> apiGameTemplatePagePageGet(
      {required String? page}) {
    generatedMapping.putIfAbsent(
        GameTemplate, () => GameTemplate.fromJsonFactory);

    return _apiGameTemplatePagePageGet(page: page);
  }

  ///
  ///@param page
  @Get(path: '/api/game-template/page/{page}')
  Future<chopper.Response<List<GameTemplate>>> _apiGameTemplatePagePageGet(
      {@Path('page') required String? page});

  ///
  Future<chopper.Response<ServerCreateDiffResult>> apiImagesDifferencesPost(
      {required CreateImagesDifferencesDto? body}) {
    generatedMapping.putIfAbsent(
        ServerCreateDiffResult, () => ServerCreateDiffResult.fromJsonFactory);

    return _apiImagesDifferencesPost(body: body);
  }

  ///
  @Post(
    path: '/api/images-differences',
    optionalBody: true,
  )
  Future<chopper.Response<ServerCreateDiffResult>> _apiImagesDifferencesPost(
      {@Body() required CreateImagesDifferencesDto? body});

  ///
  Future<chopper.Response<JwtTokenDto>> apiAuthLoginPost(
      {required LoginDto? body}) {
    generatedMapping.putIfAbsent(
        JwtTokenDto, () => JwtTokenDto.fromJsonFactory);

    return _apiAuthLoginPost(body: body);
  }

  ///
  @Post(
    path: '/api/auth/login',
    optionalBody: true,
  )
  Future<chopper.Response<JwtTokenDto>> _apiAuthLoginPost(
      {@Body() required LoginDto? body});

  ///
  Future<chopper.Response<JwtTokenDto>> apiAuthRegisterPost(
      {required CreateUserDto? body}) {
    generatedMapping.putIfAbsent(
        JwtTokenDto, () => JwtTokenDto.fromJsonFactory);

    return _apiAuthRegisterPost(body: body);
  }

  ///
  @Post(
    path: '/api/auth/register',
    optionalBody: true,
  )
  Future<chopper.Response<JwtTokenDto>> _apiAuthRegisterPost(
      {@Body() required CreateUserDto? body});

  ///
  Future<chopper.Response<JwtTokenDto>> apiAuthRefreshJwtGet() {
    generatedMapping.putIfAbsent(
        JwtTokenDto, () => JwtTokenDto.fromJsonFactory);

    return _apiAuthRefreshJwtGet();
  }

  ///
  @Get(path: '/api/auth/refresh-jwt')
  Future<chopper.Response<JwtTokenDto>> _apiAuthRefreshJwtGet();

  ///
  Future<chopper.Response> apiAuthChangePasswordPost(
      {required ChangePasswordDto? body}) {
    return _apiAuthChangePasswordPost(body: body);
  }

  ///
  @Post(
    path: '/api/auth/changePassword',
    optionalBody: true,
  )
  Future<chopper.Response> _apiAuthChangePasswordPost(
      {@Body() required ChangePasswordDto? body});

  ///
  Future<chopper.Response<List<Object>>> apiUserGet() {
    return _apiUserGet();
  }

  ///
  @Get(path: '/api/user')
  Future<chopper.Response<List<Object>>> _apiUserGet();

  ///
  Future<chopper.Response<UserDto>> apiUserProfileGet() {
    generatedMapping.putIfAbsent(UserDto, () => UserDto.fromJsonFactory);

    return _apiUserProfileGet();
  }

  ///
  @Get(path: '/api/user/profile')
  Future<chopper.Response<UserDto>> _apiUserProfileGet();

  ///
  Future<chopper.Response<Theme>> apiUserThemeGet() {
    generatedMapping.putIfAbsent(Theme, () => Theme.fromJsonFactory);

    return _apiUserThemeGet();
  }

  ///
  @Get(path: '/api/user/theme')
  Future<chopper.Response<Theme>> _apiUserThemeGet();

  ///
  Future<chopper.Response> apiUserThemePatch({required Theme? body}) {
    return _apiUserThemePatch(body: body);
  }

  ///
  @Patch(
    path: '/api/user/theme',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserThemePatch({@Body() required Theme? body});

  ///
  ///@param username
  Future<chopper.Response<List<num>>> apiUserStatsUsernameGet(
      {required String? username}) {
    return _apiUserStatsUsernameGet(username: username);
  }

  ///
  ///@param username
  @Get(path: '/api/user/stats/{username}')
  Future<chopper.Response<List<num>>> _apiUserStatsUsernameGet(
      {@Path('username') required String? username});

  ///
  Future<chopper.Response<num>> apiUserBalanceGet() {
    return _apiUserBalanceGet();
  }

  ///
  @Get(path: '/api/user/balance')
  Future<chopper.Response<num>> _apiUserBalanceGet();

  ///
  Future<chopper.Response> apiUserStatsPatch(
      {required DifferenceFoundRatioDto? body}) {
    return _apiUserStatsPatch(body: body);
  }

  ///
  @Patch(
    path: '/api/user/stats',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserStatsPatch(
      {@Body() required DifferenceFoundRatioDto? body});

  ///
  Future<chopper.Response<List<ReceiveReplayDto>>> apiUserReplaysGet() {
    generatedMapping.putIfAbsent(
        ReceiveReplayDto, () => ReceiveReplayDto.fromJsonFactory);

    return _apiUserReplaysGet();
  }

  ///
  @Get(path: '/api/user/replays')
  Future<chopper.Response<List<ReceiveReplayDto>>> _apiUserReplaysGet();

  ///
  Future<chopper.Response> apiUserAddReplayPost(
      {required SendReplayDto? body}) {
    return _apiUserAddReplayPost(body: body);
  }

  ///
  @Post(
    path: '/api/user/addReplay',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserAddReplayPost(
      {@Body() required SendReplayDto? body});

  ///
  ///@param replayId
  Future<chopper.Response> apiUserDeleteReplayReplayIdDelete(
      {required String? replayId}) {
    return _apiUserDeleteReplayReplayIdDelete(replayId: replayId);
  }

  ///
  ///@param replayId
  @Delete(path: '/api/user/deleteReplay/{replayId}')
  Future<chopper.Response> _apiUserDeleteReplayReplayIdDelete(
      {@Path('replayId') required String? replayId});

  ///
  Future<chopper.Response<LocaleDto>> apiUserLocaleGet() {
    generatedMapping.putIfAbsent(LocaleDto, () => LocaleDto.fromJsonFactory);

    return _apiUserLocaleGet();
  }

  ///
  @Get(path: '/api/user/locale')
  Future<chopper.Response<LocaleDto>> _apiUserLocaleGet();

  ///
  Future<chopper.Response> apiUserLocalePatch({required LocaleDto? body}) {
    return _apiUserLocalePatch(body: body);
  }

  ///
  @Patch(
    path: '/api/user/locale',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserLocalePatch(
      {@Body() required LocaleDto? body});

  ///
  Future<chopper.Response> apiUserUsernamePatch({required UsernameDto? body}) {
    return _apiUserUsernamePatch(body: body);
  }

  ///
  @Patch(
    path: '/api/user/username',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserUsernamePatch(
      {@Body() required UsernameDto? body});

  ///
  Future<chopper.Response> apiUserChangeAvatarPatch(
      {required ChangeAvatarDto? body}) {
    return _apiUserChangeAvatarPatch(body: body);
  }

  ///
  @Patch(
    path: '/api/user/change-avatar',
    optionalBody: true,
  )
  Future<chopper.Response> _apiUserChangeAvatarPatch(
      {@Body() required ChangeAvatarDto? body});

  ///
  Future<chopper.Response<List<History>>> apiHistoryGet() {
    generatedMapping.putIfAbsent(History, () => History.fromJsonFactory);

    return _apiHistoryGet();
  }

  ///
  @Get(path: '/api/history')
  Future<chopper.Response<List<History>>> _apiHistoryGet();

  ///
  Future<chopper.Response> apiHistoryDelete() {
    return _apiHistoryDelete();
  }

  ///
  @Delete(path: '/api/history')
  Future<chopper.Response> _apiHistoryDelete();

  ///
  ///@param username
  Future<chopper.Response<List<History>>> apiHistoryUsernameGet(
      {required String? username}) {
    generatedMapping.putIfAbsent(History, () => History.fromJsonFactory);

    return _apiHistoryUsernameGet(username: username);
  }

  ///
  ///@param username
  @Get(path: '/api/history/{username}')
  Future<chopper.Response<List<History>>> _apiHistoryUsernameGet(
      {@Path('username') required String? username});

  ///
  Future<chopper.Response<List<ChatSchema>>> apiChatAvailableChatsGet() {
    generatedMapping.putIfAbsent(ChatSchema, () => ChatSchema.fromJsonFactory);

    return _apiChatAvailableChatsGet();
  }

  ///
  @Get(path: '/api/chat/available-chats')
  Future<chopper.Response<List<ChatSchema>>> _apiChatAvailableChatsGet();

  ///
  Future<chopper.Response<List<ChatIdSchema>>> apiChatJoinedChatsGet() {
    generatedMapping.putIfAbsent(
        ChatIdSchema, () => ChatIdSchema.fromJsonFactory);

    return _apiChatJoinedChatsGet();
  }

  ///
  @Get(path: '/api/chat/joined-chats')
  Future<chopper.Response<List<ChatIdSchema>>> _apiChatJoinedChatsGet();

  ///
  Future<chopper.Response<ChatIdSchema>> apiChatGeneralChatIdGet() {
    generatedMapping.putIfAbsent(
        ChatIdSchema, () => ChatIdSchema.fromJsonFactory);

    return _apiChatGeneralChatIdGet();
  }

  ///
  @Get(path: '/api/chat/general-chat-id')
  Future<chopper.Response<ChatIdSchema>> _apiChatGeneralChatIdGet();

  ///
  Future<chopper.Response<List<String>>> apiFriendsFriendListGet() {
    return _apiFriendsFriendListGet();
  }

  ///
  @Get(path: '/api/friends/friend-list')
  Future<chopper.Response<List<String>>> _apiFriendsFriendListGet();

  ///
  ///@param username
  Future<chopper.Response<List<String>>> apiFriendsFriendListUsernameGet(
      {required String? username}) {
    return _apiFriendsFriendListUsernameGet(username: username);
  }

  ///
  ///@param username
  @Get(path: '/api/friends/friend-list/{username}')
  Future<chopper.Response<List<String>>> _apiFriendsFriendListUsernameGet(
      {@Path('username') required String? username});

  ///
  Future<chopper.Response<List<String>>> apiFriendsOutgoingRequestListGet() {
    return _apiFriendsOutgoingRequestListGet();
  }

  ///
  @Get(path: '/api/friends/outgoing-request-list')
  Future<chopper.Response<List<String>>> _apiFriendsOutgoingRequestListGet();

  ///
  Future<chopper.Response<List<String>>> apiFriendsIncomingRequestListGet() {
    return _apiFriendsIncomingRequestListGet();
  }

  ///
  @Get(path: '/api/friends/incoming-request-list')
  Future<chopper.Response<List<String>>> _apiFriendsIncomingRequestListGet();

  ///
  Future<chopper.Response<List<AccountHistory>>> apiAccountHistoryGet() {
    generatedMapping.putIfAbsent(
        AccountHistory, () => AccountHistory.fromJsonFactory);

    return _apiAccountHistoryGet();
  }

  ///
  @Get(path: '/api/account-history')
  Future<chopper.Response<List<AccountHistory>>> _apiAccountHistoryGet();

  ///
  Future<chopper.Response> apiAccountHistoryDelete() {
    return _apiAccountHistoryDelete();
  }

  ///
  @Delete(path: '/api/account-history')
  Future<chopper.Response> _apiAccountHistoryDelete();

  ///
  ///@param username
  Future<chopper.Response<List<AccountHistory>>> apiAccountHistoryUsernameGet(
      {required String? username}) {
    generatedMapping.putIfAbsent(
        AccountHistory, () => AccountHistory.fromJsonFactory);

    return _apiAccountHistoryUsernameGet(username: username);
  }

  ///
  ///@param username
  @Get(path: '/api/account-history/{username}')
  Future<chopper.Response<List<AccountHistory>>> _apiAccountHistoryUsernameGet(
      {@Path('username') required String? username});

  ///
  Future<chopper.Response> apiMarketBuyGamePost({required BuyGameDto? body}) {
    return _apiMarketBuyGamePost(body: body);
  }

  ///
  @Post(
    path: '/api/market/buyGame',
    optionalBody: true,
  )
  Future<chopper.Response> _apiMarketBuyGamePost(
      {@Body() required BuyGameDto? body});

  ///
  Future<chopper.Response<List<GameTemplate>>> apiMarketBuyableGamesGet() {
    generatedMapping.putIfAbsent(
        GameTemplate, () => GameTemplate.fromJsonFactory);

    return _apiMarketBuyableGamesGet();
  }

  ///
  @Get(path: '/api/market/buyableGames')
  Future<chopper.Response<List<GameTemplate>>> _apiMarketBuyableGamesGet();

  ///
  Future<chopper.Response<List<GameTemplate>>> apiMarketAvailableGamesGet() {
    generatedMapping.putIfAbsent(
        GameTemplate, () => GameTemplate.fromJsonFactory);

    return _apiMarketAvailableGamesGet();
  }

  ///
  @Get(path: '/api/market/availableGames')
  Future<chopper.Response<List<GameTemplate>>> _apiMarketAvailableGamesGet();
}

@JsonSerializable(explicitToJson: true)
class GameTemplate {
  const GameTemplate({
    required this.id,
    required this.name,
    required this.deleted,
    required this.difficulty,
    required this.firstImage,
    required this.secondImage,
    required this.price,
    required this.creator,
    required this.nGroups,
  });

  factory GameTemplate.fromJson(Map<String, dynamic> json) =>
      _$GameTemplateFromJson(json);

  static const toJsonFactory = _$GameTemplateToJson;
  Map<String, dynamic> toJson() => _$GameTemplateToJson(this);

  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'deleted')
  final bool deleted;
  @JsonKey(
    name: 'difficulty',
    toJson: gameTemplateDifficultyToJson,
    fromJson: gameTemplateDifficultyFromJson,
  )
  final enums.GameTemplateDifficulty difficulty;
  @JsonKey(name: 'firstImage')
  final String firstImage;
  @JsonKey(name: 'secondImage')
  final String secondImage;
  @JsonKey(name: 'price')
  final double price;
  @JsonKey(name: 'creator')
  final String creator;
  @JsonKey(name: 'nGroups')
  final double nGroups;
  static const fromJsonFactory = _$GameTemplateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GameTemplate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.deleted, deleted) ||
                const DeepCollectionEquality()
                    .equals(other.deleted, deleted)) &&
            (identical(other.difficulty, difficulty) ||
                const DeepCollectionEquality()
                    .equals(other.difficulty, difficulty)) &&
            (identical(other.firstImage, firstImage) ||
                const DeepCollectionEquality()
                    .equals(other.firstImage, firstImage)) &&
            (identical(other.secondImage, secondImage) ||
                const DeepCollectionEquality()
                    .equals(other.secondImage, secondImage)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.creator, creator) ||
                const DeepCollectionEquality()
                    .equals(other.creator, creator)) &&
            (identical(other.nGroups, nGroups) ||
                const DeepCollectionEquality().equals(other.nGroups, nGroups)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(deleted) ^
      const DeepCollectionEquality().hash(difficulty) ^
      const DeepCollectionEquality().hash(firstImage) ^
      const DeepCollectionEquality().hash(secondImage) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(creator) ^
      const DeepCollectionEquality().hash(nGroups) ^
      runtimeType.hashCode;
}

extension $GameTemplateExtension on GameTemplate {
  GameTemplate copyWith(
      {String? id,
      String? name,
      bool? deleted,
      enums.GameTemplateDifficulty? difficulty,
      String? firstImage,
      String? secondImage,
      double? price,
      String? creator,
      double? nGroups}) {
    return GameTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        deleted: deleted ?? this.deleted,
        difficulty: difficulty ?? this.difficulty,
        firstImage: firstImage ?? this.firstImage,
        secondImage: secondImage ?? this.secondImage,
        price: price ?? this.price,
        creator: creator ?? this.creator,
        nGroups: nGroups ?? this.nGroups);
  }

  GameTemplate copyWithWrapped(
      {Wrapped<String>? id,
      Wrapped<String>? name,
      Wrapped<bool>? deleted,
      Wrapped<enums.GameTemplateDifficulty>? difficulty,
      Wrapped<String>? firstImage,
      Wrapped<String>? secondImage,
      Wrapped<double>? price,
      Wrapped<String>? creator,
      Wrapped<double>? nGroups}) {
    return GameTemplate(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        deleted: (deleted != null ? deleted.value : this.deleted),
        difficulty: (difficulty != null ? difficulty.value : this.difficulty),
        firstImage: (firstImage != null ? firstImage.value : this.firstImage),
        secondImage:
            (secondImage != null ? secondImage.value : this.secondImage),
        price: (price != null ? price.value : this.price),
        creator: (creator != null ? creator.value : this.creator),
        nGroups: (nGroups != null ? nGroups.value : this.nGroups));
  }
}

@JsonSerializable(explicitToJson: true)
class ServerCreateGameDto {
  const ServerCreateGameDto({
    required this.name,
    required this.firstImage,
    required this.secondImage,
    required this.radius,
    required this.price,
  });

  factory ServerCreateGameDto.fromJson(Map<String, dynamic> json) =>
      _$ServerCreateGameDtoFromJson(json);

  static const toJsonFactory = _$ServerCreateGameDtoToJson;
  Map<String, dynamic> toJson() => _$ServerCreateGameDtoToJson(this);

  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'firstImage')
  final String firstImage;
  @JsonKey(name: 'secondImage')
  final String secondImage;
  @JsonKey(name: 'radius')
  final double radius;
  @JsonKey(name: 'price')
  final double price;
  static const fromJsonFactory = _$ServerCreateGameDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerCreateGameDto &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.firstImage, firstImage) ||
                const DeepCollectionEquality()
                    .equals(other.firstImage, firstImage)) &&
            (identical(other.secondImage, secondImage) ||
                const DeepCollectionEquality()
                    .equals(other.secondImage, secondImage)) &&
            (identical(other.radius, radius) ||
                const DeepCollectionEquality().equals(other.radius, radius)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(firstImage) ^
      const DeepCollectionEquality().hash(secondImage) ^
      const DeepCollectionEquality().hash(radius) ^
      const DeepCollectionEquality().hash(price) ^
      runtimeType.hashCode;
}

extension $ServerCreateGameDtoExtension on ServerCreateGameDto {
  ServerCreateGameDto copyWith(
      {String? name,
      String? firstImage,
      String? secondImage,
      double? radius,
      double? price}) {
    return ServerCreateGameDto(
        name: name ?? this.name,
        firstImage: firstImage ?? this.firstImage,
        secondImage: secondImage ?? this.secondImage,
        radius: radius ?? this.radius,
        price: price ?? this.price);
  }

  ServerCreateGameDto copyWithWrapped(
      {Wrapped<String>? name,
      Wrapped<String>? firstImage,
      Wrapped<String>? secondImage,
      Wrapped<double>? radius,
      Wrapped<double>? price}) {
    return ServerCreateGameDto(
        name: (name != null ? name.value : this.name),
        firstImage: (firstImage != null ? firstImage.value : this.firstImage),
        secondImage:
            (secondImage != null ? secondImage.value : this.secondImage),
        radius: (radius != null ? radius.value : this.radius),
        price: (price != null ? price.value : this.price));
  }
}

@JsonSerializable(explicitToJson: true)
class ErrorResponseDto {
  const ErrorResponseDto({
    required this.statusCode,
    required this.message,
    required this.error,
  });

  factory ErrorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseDtoFromJson(json);

  static const toJsonFactory = _$ErrorResponseDtoToJson;
  Map<String, dynamic> toJson() => _$ErrorResponseDtoToJson(this);

  @JsonKey(name: 'statusCode')
  final double statusCode;
  @JsonKey(
    name: 'message',
    toJson: errorResponseDtoMessageToJson,
    fromJson: errorResponseDtoMessageFromJson,
  )
  final enums.ErrorResponseDtoMessage message;
  @JsonKey(name: 'error')
  final String error;
  static const fromJsonFactory = _$ErrorResponseDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorResponseDto &&
            (identical(other.statusCode, statusCode) ||
                const DeepCollectionEquality()
                    .equals(other.statusCode, statusCode)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality()
                    .equals(other.message, message)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(statusCode) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(error) ^
      runtimeType.hashCode;
}

extension $ErrorResponseDtoExtension on ErrorResponseDto {
  ErrorResponseDto copyWith(
      {double? statusCode,
      enums.ErrorResponseDtoMessage? message,
      String? error}) {
    return ErrorResponseDto(
        statusCode: statusCode ?? this.statusCode,
        message: message ?? this.message,
        error: error ?? this.error);
  }

  ErrorResponseDto copyWithWrapped(
      {Wrapped<double>? statusCode,
      Wrapped<enums.ErrorResponseDtoMessage>? message,
      Wrapped<String>? error}) {
    return ErrorResponseDto(
        statusCode: (statusCode != null ? statusCode.value : this.statusCode),
        message: (message != null ? message.value : this.message),
        error: (error != null ? error.value : this.error));
  }
}

@JsonSerializable(explicitToJson: true)
class CreateImagesDifferencesDto {
  const CreateImagesDifferencesDto({
    required this.image1Base64,
    required this.image2Base64,
    required this.radius,
  });

  factory CreateImagesDifferencesDto.fromJson(Map<String, dynamic> json) =>
      _$CreateImagesDifferencesDtoFromJson(json);

  static const toJsonFactory = _$CreateImagesDifferencesDtoToJson;
  Map<String, dynamic> toJson() => _$CreateImagesDifferencesDtoToJson(this);

  @JsonKey(name: 'image1Base64')
  final String image1Base64;
  @JsonKey(name: 'image2Base64')
  final String image2Base64;
  @JsonKey(name: 'radius')
  final double radius;
  static const fromJsonFactory = _$CreateImagesDifferencesDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateImagesDifferencesDto &&
            (identical(other.image1Base64, image1Base64) ||
                const DeepCollectionEquality()
                    .equals(other.image1Base64, image1Base64)) &&
            (identical(other.image2Base64, image2Base64) ||
                const DeepCollectionEquality()
                    .equals(other.image2Base64, image2Base64)) &&
            (identical(other.radius, radius) ||
                const DeepCollectionEquality().equals(other.radius, radius)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(image1Base64) ^
      const DeepCollectionEquality().hash(image2Base64) ^
      const DeepCollectionEquality().hash(radius) ^
      runtimeType.hashCode;
}

extension $CreateImagesDifferencesDtoExtension on CreateImagesDifferencesDto {
  CreateImagesDifferencesDto copyWith(
      {String? image1Base64, String? image2Base64, double? radius}) {
    return CreateImagesDifferencesDto(
        image1Base64: image1Base64 ?? this.image1Base64,
        image2Base64: image2Base64 ?? this.image2Base64,
        radius: radius ?? this.radius);
  }

  CreateImagesDifferencesDto copyWithWrapped(
      {Wrapped<String>? image1Base64,
      Wrapped<String>? image2Base64,
      Wrapped<double>? radius}) {
    return CreateImagesDifferencesDto(
        image1Base64:
            (image1Base64 != null ? image1Base64.value : this.image1Base64),
        image2Base64:
            (image2Base64 != null ? image2Base64.value : this.image2Base64),
        radius: (radius != null ? radius.value : this.radius));
  }
}

@JsonSerializable(explicitToJson: true)
class ServerCreateDiffResult {
  const ServerCreateDiffResult({
    required this.nGroups,
    required this.difficulty,
    required this.diffImage,
  });

  factory ServerCreateDiffResult.fromJson(Map<String, dynamic> json) =>
      _$ServerCreateDiffResultFromJson(json);

  static const toJsonFactory = _$ServerCreateDiffResultToJson;
  Map<String, dynamic> toJson() => _$ServerCreateDiffResultToJson(this);

  @JsonKey(name: 'nGroups')
  final double nGroups;
  @JsonKey(
    name: 'difficulty',
    toJson: serverCreateDiffResultDifficultyToJson,
    fromJson: serverCreateDiffResultDifficultyFromJson,
  )
  final enums.ServerCreateDiffResultDifficulty difficulty;
  @JsonKey(name: 'diffImage')
  final String diffImage;
  static const fromJsonFactory = _$ServerCreateDiffResultFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerCreateDiffResult &&
            (identical(other.nGroups, nGroups) ||
                const DeepCollectionEquality()
                    .equals(other.nGroups, nGroups)) &&
            (identical(other.difficulty, difficulty) ||
                const DeepCollectionEquality()
                    .equals(other.difficulty, difficulty)) &&
            (identical(other.diffImage, diffImage) ||
                const DeepCollectionEquality()
                    .equals(other.diffImage, diffImage)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(nGroups) ^
      const DeepCollectionEquality().hash(difficulty) ^
      const DeepCollectionEquality().hash(diffImage) ^
      runtimeType.hashCode;
}

extension $ServerCreateDiffResultExtension on ServerCreateDiffResult {
  ServerCreateDiffResult copyWith(
      {double? nGroups,
      enums.ServerCreateDiffResultDifficulty? difficulty,
      String? diffImage}) {
    return ServerCreateDiffResult(
        nGroups: nGroups ?? this.nGroups,
        difficulty: difficulty ?? this.difficulty,
        diffImage: diffImage ?? this.diffImage);
  }

  ServerCreateDiffResult copyWithWrapped(
      {Wrapped<double>? nGroups,
      Wrapped<enums.ServerCreateDiffResultDifficulty>? difficulty,
      Wrapped<String>? diffImage}) {
    return ServerCreateDiffResult(
        nGroups: (nGroups != null ? nGroups.value : this.nGroups),
        difficulty: (difficulty != null ? difficulty.value : this.difficulty),
        diffImage: (diffImage != null ? diffImage.value : this.diffImage));
  }
}

@JsonSerializable(explicitToJson: true)
class LoginDto {
  const LoginDto({
    required this.username,
    required this.password,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);

  static const toJsonFactory = _$LoginDtoToJson;
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);

  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'password')
  final String password;
  static const fromJsonFactory = _$LoginDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoginDto &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality()
                    .equals(other.password, password)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $LoginDtoExtension on LoginDto {
  LoginDto copyWith({String? username, String? password}) {
    return LoginDto(
        username: username ?? this.username,
        password: password ?? this.password);
  }

  LoginDto copyWithWrapped(
      {Wrapped<String>? username, Wrapped<String>? password}) {
    return LoginDto(
        username: (username != null ? username.value : this.username),
        password: (password != null ? password.value : this.password));
  }
}

@JsonSerializable(explicitToJson: true)
class JwtTokenDto {
  const JwtTokenDto({
    required this.accessToken,
  });

  factory JwtTokenDto.fromJson(Map<String, dynamic> json) =>
      _$JwtTokenDtoFromJson(json);

  static const toJsonFactory = _$JwtTokenDtoToJson;
  Map<String, dynamic> toJson() => _$JwtTokenDtoToJson(this);

  @JsonKey(name: 'accessToken')
  final String accessToken;
  static const fromJsonFactory = _$JwtTokenDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is JwtTokenDto &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality()
                    .equals(other.accessToken, accessToken)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accessToken) ^ runtimeType.hashCode;
}

extension $JwtTokenDtoExtension on JwtTokenDto {
  JwtTokenDto copyWith({String? accessToken}) {
    return JwtTokenDto(accessToken: accessToken ?? this.accessToken);
  }

  JwtTokenDto copyWithWrapped({Wrapped<String>? accessToken}) {
    return JwtTokenDto(
        accessToken:
            (accessToken != null ? accessToken.value : this.accessToken));
  }
}

@JsonSerializable(explicitToJson: true)
class CreateUserDto {
  const CreateUserDto({
    required this.username,
    required this.avatarUrl,
    required this.password,
  });

  factory CreateUserDto.fromJson(Map<String, dynamic> json) =>
      _$CreateUserDtoFromJson(json);

  static const toJsonFactory = _$CreateUserDtoToJson;
  Map<String, dynamic> toJson() => _$CreateUserDtoToJson(this);

  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'avatarUrl')
  final String avatarUrl;
  @JsonKey(name: 'password')
  final String password;
  static const fromJsonFactory = _$CreateUserDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateUserDto &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.avatarUrl, avatarUrl) ||
                const DeepCollectionEquality()
                    .equals(other.avatarUrl, avatarUrl)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality()
                    .equals(other.password, password)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(avatarUrl) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $CreateUserDtoExtension on CreateUserDto {
  CreateUserDto copyWith(
      {String? username, String? avatarUrl, String? password}) {
    return CreateUserDto(
        username: username ?? this.username,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        password: password ?? this.password);
  }

  CreateUserDto copyWithWrapped(
      {Wrapped<String>? username,
      Wrapped<String>? avatarUrl,
      Wrapped<String>? password}) {
    return CreateUserDto(
        username: (username != null ? username.value : this.username),
        avatarUrl: (avatarUrl != null ? avatarUrl.value : this.avatarUrl),
        password: (password != null ? password.value : this.password));
  }
}

@JsonSerializable(explicitToJson: true)
class ChangePasswordDto {
  const ChangePasswordDto({
    required this.password,
  });

  factory ChangePasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDtoFromJson(json);

  static const toJsonFactory = _$ChangePasswordDtoToJson;
  Map<String, dynamic> toJson() => _$ChangePasswordDtoToJson(this);

  @JsonKey(name: 'password')
  final String password;
  static const fromJsonFactory = _$ChangePasswordDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChangePasswordDto &&
            (identical(other.password, password) ||
                const DeepCollectionEquality()
                    .equals(other.password, password)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(password) ^ runtimeType.hashCode;
}

extension $ChangePasswordDtoExtension on ChangePasswordDto {
  ChangePasswordDto copyWith({String? password}) {
    return ChangePasswordDto(password: password ?? this.password);
  }

  ChangePasswordDto copyWithWrapped({Wrapped<String>? password}) {
    return ChangePasswordDto(
        password: (password != null ? password.value : this.password));
  }
}

@JsonSerializable(explicitToJson: true)
class UserDto {
  const UserDto({
    required this.avatarUrl,
    required this.username,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  static const toJsonFactory = _$UserDtoToJson;
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  @JsonKey(name: 'avatarUrl')
  final String avatarUrl;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$UserDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserDto &&
            (identical(other.avatarUrl, avatarUrl) ||
                const DeepCollectionEquality()
                    .equals(other.avatarUrl, avatarUrl)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(avatarUrl) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $UserDtoExtension on UserDto {
  UserDto copyWith({String? avatarUrl, String? username}) {
    return UserDto(
        avatarUrl: avatarUrl ?? this.avatarUrl,
        username: username ?? this.username);
  }

  UserDto copyWithWrapped(
      {Wrapped<String>? avatarUrl, Wrapped<String>? username}) {
    return UserDto(
        avatarUrl: (avatarUrl != null ? avatarUrl.value : this.avatarUrl),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class Theme {
  const Theme({
    required this.primaryColor,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);

  static const toJsonFactory = _$ThemeToJson;
  Map<String, dynamic> toJson() => _$ThemeToJson(this);

  @JsonKey(name: 'primaryColor')
  final String primaryColor;
  static const fromJsonFactory = _$ThemeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Theme &&
            (identical(other.primaryColor, primaryColor) ||
                const DeepCollectionEquality()
                    .equals(other.primaryColor, primaryColor)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(primaryColor) ^ runtimeType.hashCode;
}

extension $ThemeExtension on Theme {
  Theme copyWith({String? primaryColor}) {
    return Theme(primaryColor: primaryColor ?? this.primaryColor);
  }

  Theme copyWithWrapped({Wrapped<String>? primaryColor}) {
    return Theme(
        primaryColor:
            (primaryColor != null ? primaryColor.value : this.primaryColor));
  }
}

@JsonSerializable(explicitToJson: true)
class DifferenceFoundRatioDto {
  const DifferenceFoundRatioDto({
    required this.differenceFound,
  });

  factory DifferenceFoundRatioDto.fromJson(Map<String, dynamic> json) =>
      _$DifferenceFoundRatioDtoFromJson(json);

  static const toJsonFactory = _$DifferenceFoundRatioDtoToJson;
  Map<String, dynamic> toJson() => _$DifferenceFoundRatioDtoToJson(this);

  @JsonKey(name: 'differenceFound')
  final double differenceFound;
  static const fromJsonFactory = _$DifferenceFoundRatioDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DifferenceFoundRatioDto &&
            (identical(other.differenceFound, differenceFound) ||
                const DeepCollectionEquality()
                    .equals(other.differenceFound, differenceFound)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(differenceFound) ^
      runtimeType.hashCode;
}

extension $DifferenceFoundRatioDtoExtension on DifferenceFoundRatioDto {
  DifferenceFoundRatioDto copyWith({double? differenceFound}) {
    return DifferenceFoundRatioDto(
        differenceFound: differenceFound ?? this.differenceFound);
  }

  DifferenceFoundRatioDto copyWithWrapped({Wrapped<double>? differenceFound}) {
    return DifferenceFoundRatioDto(
        differenceFound: (differenceFound != null
            ? differenceFound.value
            : this.differenceFound));
  }
}

@JsonSerializable(explicitToJson: true)
class ReplayEvent {
  const ReplayEvent({
    required this.name,
    required this.time,
    required this.data,
  });

  factory ReplayEvent.fromJson(Map<String, dynamic> json) =>
      _$ReplayEventFromJson(json);

  static const toJsonFactory = _$ReplayEventToJson;
  Map<String, dynamic> toJson() => _$ReplayEventToJson(this);

  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'time')
  final double time;
  @JsonKey(name: 'data')
  final Object data;
  static const fromJsonFactory = _$ReplayEventFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReplayEvent &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.time, time) ||
                const DeepCollectionEquality().equals(other.time, time)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(time) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $ReplayEventExtension on ReplayEvent {
  ReplayEvent copyWith({String? name, double? time, Object? data}) {
    return ReplayEvent(
        name: name ?? this.name,
        time: time ?? this.time,
        data: data ?? this.data);
  }

  ReplayEvent copyWithWrapped(
      {Wrapped<String>? name, Wrapped<double>? time, Wrapped<Object>? data}) {
    return ReplayEvent(
        name: (name != null ? name.value : this.name),
        time: (time != null ? time.value : this.time),
        data: (data != null ? data.value : this.data));
  }
}

@JsonSerializable(explicitToJson: true)
class ReceiveReplayDto {
  const ReceiveReplayDto({
    required this.id,
    required this.events,
    required this.gameTemplateId,
    required this.gameMode,
    required this.username,
  });

  factory ReceiveReplayDto.fromJson(Map<String, dynamic> json) =>
      _$ReceiveReplayDtoFromJson(json);

  static const toJsonFactory = _$ReceiveReplayDtoToJson;
  Map<String, dynamic> toJson() => _$ReceiveReplayDtoToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'events', defaultValue: <ReplayEvent>[])
  final List<ReplayEvent> events;
  @JsonKey(name: 'gameTemplateId')
  final String gameTemplateId;
  @JsonKey(
    name: 'gameMode',
    toJson: receiveReplayDtoGameModeToJson,
    fromJson: receiveReplayDtoGameModeFromJson,
  )
  final enums.ReceiveReplayDtoGameMode gameMode;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$ReceiveReplayDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReceiveReplayDto &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.events, events) ||
                const DeepCollectionEquality().equals(other.events, events)) &&
            (identical(other.gameTemplateId, gameTemplateId) ||
                const DeepCollectionEquality()
                    .equals(other.gameTemplateId, gameTemplateId)) &&
            (identical(other.gameMode, gameMode) ||
                const DeepCollectionEquality()
                    .equals(other.gameMode, gameMode)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(events) ^
      const DeepCollectionEquality().hash(gameTemplateId) ^
      const DeepCollectionEquality().hash(gameMode) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $ReceiveReplayDtoExtension on ReceiveReplayDto {
  ReceiveReplayDto copyWith(
      {String? id,
      List<ReplayEvent>? events,
      String? gameTemplateId,
      enums.ReceiveReplayDtoGameMode? gameMode,
      String? username}) {
    return ReceiveReplayDto(
        id: id ?? this.id,
        events: events ?? this.events,
        gameTemplateId: gameTemplateId ?? this.gameTemplateId,
        gameMode: gameMode ?? this.gameMode,
        username: username ?? this.username);
  }

  ReceiveReplayDto copyWithWrapped(
      {Wrapped<String>? id,
      Wrapped<List<ReplayEvent>>? events,
      Wrapped<String>? gameTemplateId,
      Wrapped<enums.ReceiveReplayDtoGameMode>? gameMode,
      Wrapped<String>? username}) {
    return ReceiveReplayDto(
        id: (id != null ? id.value : this.id),
        events: (events != null ? events.value : this.events),
        gameTemplateId: (gameTemplateId != null
            ? gameTemplateId.value
            : this.gameTemplateId),
        gameMode: (gameMode != null ? gameMode.value : this.gameMode),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class SendReplayDto {
  const SendReplayDto({
    required this.events,
    required this.gameTemplateId,
    required this.gameMode,
  });

  factory SendReplayDto.fromJson(Map<String, dynamic> json) =>
      _$SendReplayDtoFromJson(json);

  static const toJsonFactory = _$SendReplayDtoToJson;
  Map<String, dynamic> toJson() => _$SendReplayDtoToJson(this);

  @JsonKey(name: 'events', defaultValue: <ReplayEvent>[])
  final List<ReplayEvent> events;
  @JsonKey(name: 'gameTemplateId')
  final String gameTemplateId;
  @JsonKey(
    name: 'gameMode',
    toJson: sendReplayDtoGameModeToJson,
    fromJson: sendReplayDtoGameModeFromJson,
  )
  final enums.SendReplayDtoGameMode gameMode;
  static const fromJsonFactory = _$SendReplayDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SendReplayDto &&
            (identical(other.events, events) ||
                const DeepCollectionEquality().equals(other.events, events)) &&
            (identical(other.gameTemplateId, gameTemplateId) ||
                const DeepCollectionEquality()
                    .equals(other.gameTemplateId, gameTemplateId)) &&
            (identical(other.gameMode, gameMode) ||
                const DeepCollectionEquality()
                    .equals(other.gameMode, gameMode)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(events) ^
      const DeepCollectionEquality().hash(gameTemplateId) ^
      const DeepCollectionEquality().hash(gameMode) ^
      runtimeType.hashCode;
}

extension $SendReplayDtoExtension on SendReplayDto {
  SendReplayDto copyWith(
      {List<ReplayEvent>? events,
      String? gameTemplateId,
      enums.SendReplayDtoGameMode? gameMode}) {
    return SendReplayDto(
        events: events ?? this.events,
        gameTemplateId: gameTemplateId ?? this.gameTemplateId,
        gameMode: gameMode ?? this.gameMode);
  }

  SendReplayDto copyWithWrapped(
      {Wrapped<List<ReplayEvent>>? events,
      Wrapped<String>? gameTemplateId,
      Wrapped<enums.SendReplayDtoGameMode>? gameMode}) {
    return SendReplayDto(
        events: (events != null ? events.value : this.events),
        gameTemplateId: (gameTemplateId != null
            ? gameTemplateId.value
            : this.gameTemplateId),
        gameMode: (gameMode != null ? gameMode.value : this.gameMode));
  }
}

@JsonSerializable(explicitToJson: true)
class LocaleDto {
  const LocaleDto({
    required this.locale,
  });

  factory LocaleDto.fromJson(Map<String, dynamic> json) =>
      _$LocaleDtoFromJson(json);

  static const toJsonFactory = _$LocaleDtoToJson;
  Map<String, dynamic> toJson() => _$LocaleDtoToJson(this);

  @JsonKey(name: 'locale')
  final String locale;
  static const fromJsonFactory = _$LocaleDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LocaleDto &&
            (identical(other.locale, locale) ||
                const DeepCollectionEquality().equals(other.locale, locale)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(locale) ^ runtimeType.hashCode;
}

extension $LocaleDtoExtension on LocaleDto {
  LocaleDto copyWith({String? locale}) {
    return LocaleDto(locale: locale ?? this.locale);
  }

  LocaleDto copyWithWrapped({Wrapped<String>? locale}) {
    return LocaleDto(locale: (locale != null ? locale.value : this.locale));
  }
}

@JsonSerializable(explicitToJson: true)
class UsernameDto {
  const UsernameDto({
    required this.username,
  });

  factory UsernameDto.fromJson(Map<String, dynamic> json) =>
      _$UsernameDtoFromJson(json);

  static const toJsonFactory = _$UsernameDtoToJson;
  Map<String, dynamic> toJson() => _$UsernameDtoToJson(this);

  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$UsernameDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UsernameDto &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^ runtimeType.hashCode;
}

extension $UsernameDtoExtension on UsernameDto {
  UsernameDto copyWith({String? username}) {
    return UsernameDto(username: username ?? this.username);
  }

  UsernameDto copyWithWrapped({Wrapped<String>? username}) {
    return UsernameDto(
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class ChangeAvatarDto {
  const ChangeAvatarDto({
    required this.avatarUrl,
  });

  factory ChangeAvatarDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeAvatarDtoFromJson(json);

  static const toJsonFactory = _$ChangeAvatarDtoToJson;
  Map<String, dynamic> toJson() => _$ChangeAvatarDtoToJson(this);

  @JsonKey(name: 'avatarUrl')
  final String avatarUrl;
  static const fromJsonFactory = _$ChangeAvatarDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChangeAvatarDto &&
            (identical(other.avatarUrl, avatarUrl) ||
                const DeepCollectionEquality()
                    .equals(other.avatarUrl, avatarUrl)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(avatarUrl) ^ runtimeType.hashCode;
}

extension $ChangeAvatarDtoExtension on ChangeAvatarDto {
  ChangeAvatarDto copyWith({String? avatarUrl}) {
    return ChangeAvatarDto(avatarUrl: avatarUrl ?? this.avatarUrl);
  }

  ChangeAvatarDto copyWithWrapped({Wrapped<String>? avatarUrl}) {
    return ChangeAvatarDto(
        avatarUrl: (avatarUrl != null ? avatarUrl.value : this.avatarUrl));
  }
}

@JsonSerializable(explicitToJson: true)
class History {
  const History({
    required this.startTime,
    required this.totalTime,
    required this.gameMode,
    required this.winners,
    required this.losers,
    required this.quitters,
  });

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  static const toJsonFactory = _$HistoryToJson;
  Map<String, dynamic> toJson() => _$HistoryToJson(this);

  @JsonKey(name: 'startTime')
  final double startTime;
  @JsonKey(name: 'totalTime')
  final double totalTime;
  @JsonKey(
    name: 'gameMode',
    toJson: historyGameModeToJson,
    fromJson: historyGameModeFromJson,
  )
  final enums.HistoryGameMode gameMode;
  @JsonKey(name: 'winners', defaultValue: <String>[])
  final List<String> winners;
  @JsonKey(name: 'losers', defaultValue: <String>[])
  final List<String> losers;
  @JsonKey(name: 'quitters', defaultValue: <String>[])
  final List<String> quitters;
  static const fromJsonFactory = _$HistoryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is History &&
            (identical(other.startTime, startTime) ||
                const DeepCollectionEquality()
                    .equals(other.startTime, startTime)) &&
            (identical(other.totalTime, totalTime) ||
                const DeepCollectionEquality()
                    .equals(other.totalTime, totalTime)) &&
            (identical(other.gameMode, gameMode) ||
                const DeepCollectionEquality()
                    .equals(other.gameMode, gameMode)) &&
            (identical(other.winners, winners) ||
                const DeepCollectionEquality()
                    .equals(other.winners, winners)) &&
            (identical(other.losers, losers) ||
                const DeepCollectionEquality().equals(other.losers, losers)) &&
            (identical(other.quitters, quitters) ||
                const DeepCollectionEquality()
                    .equals(other.quitters, quitters)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(startTime) ^
      const DeepCollectionEquality().hash(totalTime) ^
      const DeepCollectionEquality().hash(gameMode) ^
      const DeepCollectionEquality().hash(winners) ^
      const DeepCollectionEquality().hash(losers) ^
      const DeepCollectionEquality().hash(quitters) ^
      runtimeType.hashCode;
}

extension $HistoryExtension on History {
  History copyWith(
      {double? startTime,
      double? totalTime,
      enums.HistoryGameMode? gameMode,
      List<String>? winners,
      List<String>? losers,
      List<String>? quitters}) {
    return History(
        startTime: startTime ?? this.startTime,
        totalTime: totalTime ?? this.totalTime,
        gameMode: gameMode ?? this.gameMode,
        winners: winners ?? this.winners,
        losers: losers ?? this.losers,
        quitters: quitters ?? this.quitters);
  }

  History copyWithWrapped(
      {Wrapped<double>? startTime,
      Wrapped<double>? totalTime,
      Wrapped<enums.HistoryGameMode>? gameMode,
      Wrapped<List<String>>? winners,
      Wrapped<List<String>>? losers,
      Wrapped<List<String>>? quitters}) {
    return History(
        startTime: (startTime != null ? startTime.value : this.startTime),
        totalTime: (totalTime != null ? totalTime.value : this.totalTime),
        gameMode: (gameMode != null ? gameMode.value : this.gameMode),
        winners: (winners != null ? winners.value : this.winners),
        losers: (losers != null ? losers.value : this.losers),
        quitters: (quitters != null ? quitters.value : this.quitters));
  }
}

@JsonSerializable(explicitToJson: true)
class ChatSchema {
  const ChatSchema({
    required this.chatId,
    required this.name,
    required this.creator,
  });

  factory ChatSchema.fromJson(Map<String, dynamic> json) =>
      _$ChatSchemaFromJson(json);

  static const toJsonFactory = _$ChatSchemaToJson;
  Map<String, dynamic> toJson() => _$ChatSchemaToJson(this);

  @JsonKey(name: 'chatId')
  final String chatId;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'creator')
  final String creator;
  static const fromJsonFactory = _$ChatSchemaFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatSchema &&
            (identical(other.chatId, chatId) ||
                const DeepCollectionEquality().equals(other.chatId, chatId)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.creator, creator) ||
                const DeepCollectionEquality().equals(other.creator, creator)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(chatId) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(creator) ^
      runtimeType.hashCode;
}

extension $ChatSchemaExtension on ChatSchema {
  ChatSchema copyWith({String? chatId, String? name, String? creator}) {
    return ChatSchema(
        chatId: chatId ?? this.chatId,
        name: name ?? this.name,
        creator: creator ?? this.creator);
  }

  ChatSchema copyWithWrapped(
      {Wrapped<String>? chatId,
      Wrapped<String>? name,
      Wrapped<String>? creator}) {
    return ChatSchema(
        chatId: (chatId != null ? chatId.value : this.chatId),
        name: (name != null ? name.value : this.name),
        creator: (creator != null ? creator.value : this.creator));
  }
}

@JsonSerializable(explicitToJson: true)
class ChatIdSchema {
  const ChatIdSchema({
    required this.chatId,
  });

  factory ChatIdSchema.fromJson(Map<String, dynamic> json) =>
      _$ChatIdSchemaFromJson(json);

  static const toJsonFactory = _$ChatIdSchemaToJson;
  Map<String, dynamic> toJson() => _$ChatIdSchemaToJson(this);

  @JsonKey(name: 'chatId')
  final String chatId;
  static const fromJsonFactory = _$ChatIdSchemaFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatIdSchema &&
            (identical(other.chatId, chatId) ||
                const DeepCollectionEquality().equals(other.chatId, chatId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(chatId) ^ runtimeType.hashCode;
}

extension $ChatIdSchemaExtension on ChatIdSchema {
  ChatIdSchema copyWith({String? chatId}) {
    return ChatIdSchema(chatId: chatId ?? this.chatId);
  }

  ChatIdSchema copyWithWrapped({Wrapped<String>? chatId}) {
    return ChatIdSchema(chatId: (chatId != null ? chatId.value : this.chatId));
  }
}

@JsonSerializable(explicitToJson: true)
class AccountHistory {
  const AccountHistory({
    required this.username,
    required this.action,
    required this.timestamp,
  });

  factory AccountHistory.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryFromJson(json);

  static const toJsonFactory = _$AccountHistoryToJson;
  Map<String, dynamic> toJson() => _$AccountHistoryToJson(this);

  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'action')
  final String action;
  @JsonKey(name: 'timestamp')
  final double timestamp;
  static const fromJsonFactory = _$AccountHistoryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AccountHistory &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.action, action) ||
                const DeepCollectionEquality().equals(other.action, action)) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality()
                    .equals(other.timestamp, timestamp)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(action) ^
      const DeepCollectionEquality().hash(timestamp) ^
      runtimeType.hashCode;
}

extension $AccountHistoryExtension on AccountHistory {
  AccountHistory copyWith(
      {String? username, String? action, double? timestamp}) {
    return AccountHistory(
        username: username ?? this.username,
        action: action ?? this.action,
        timestamp: timestamp ?? this.timestamp);
  }

  AccountHistory copyWithWrapped(
      {Wrapped<String>? username,
      Wrapped<String>? action,
      Wrapped<double>? timestamp}) {
    return AccountHistory(
        username: (username != null ? username.value : this.username),
        action: (action != null ? action.value : this.action),
        timestamp: (timestamp != null ? timestamp.value : this.timestamp));
  }
}

@JsonSerializable(explicitToJson: true)
class BuyGameDto {
  const BuyGameDto({
    required this.gameTemplateId,
  });

  factory BuyGameDto.fromJson(Map<String, dynamic> json) =>
      _$BuyGameDtoFromJson(json);

  static const toJsonFactory = _$BuyGameDtoToJson;
  Map<String, dynamic> toJson() => _$BuyGameDtoToJson(this);

  @JsonKey(name: 'gameTemplateId')
  final String gameTemplateId;
  static const fromJsonFactory = _$BuyGameDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BuyGameDto &&
            (identical(other.gameTemplateId, gameTemplateId) ||
                const DeepCollectionEquality()
                    .equals(other.gameTemplateId, gameTemplateId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(gameTemplateId) ^
      runtimeType.hashCode;
}

extension $BuyGameDtoExtension on BuyGameDto {
  BuyGameDto copyWith({String? gameTemplateId}) {
    return BuyGameDto(gameTemplateId: gameTemplateId ?? this.gameTemplateId);
  }

  BuyGameDto copyWithWrapped({Wrapped<String>? gameTemplateId}) {
    return BuyGameDto(
        gameTemplateId: (gameTemplateId != null
            ? gameTemplateId.value
            : this.gameTemplateId));
  }
}

String? gameTemplateDifficultyNullableToJson(
    enums.GameTemplateDifficulty? gameTemplateDifficulty) {
  return gameTemplateDifficulty?.value;
}

String? gameTemplateDifficultyToJson(
    enums.GameTemplateDifficulty gameTemplateDifficulty) {
  return gameTemplateDifficulty.value;
}

enums.GameTemplateDifficulty gameTemplateDifficultyFromJson(
  Object? gameTemplateDifficulty, [
  enums.GameTemplateDifficulty? defaultValue,
]) {
  return enums.GameTemplateDifficulty.values
          .firstWhereOrNull((e) => e.value == gameTemplateDifficulty) ??
      defaultValue ??
      enums.GameTemplateDifficulty.swaggerGeneratedUnknown;
}

enums.GameTemplateDifficulty? gameTemplateDifficultyNullableFromJson(
  Object? gameTemplateDifficulty, [
  enums.GameTemplateDifficulty? defaultValue,
]) {
  if (gameTemplateDifficulty == null) {
    return null;
  }
  return enums.GameTemplateDifficulty.values
          .firstWhereOrNull((e) => e.value == gameTemplateDifficulty) ??
      defaultValue;
}

String gameTemplateDifficultyExplodedListToJson(
    List<enums.GameTemplateDifficulty>? gameTemplateDifficulty) {
  return gameTemplateDifficulty?.map((e) => e.value!).join(',') ?? '';
}

List<String> gameTemplateDifficultyListToJson(
    List<enums.GameTemplateDifficulty>? gameTemplateDifficulty) {
  if (gameTemplateDifficulty == null) {
    return [];
  }

  return gameTemplateDifficulty.map((e) => e.value!).toList();
}

List<enums.GameTemplateDifficulty> gameTemplateDifficultyListFromJson(
  List? gameTemplateDifficulty, [
  List<enums.GameTemplateDifficulty>? defaultValue,
]) {
  if (gameTemplateDifficulty == null) {
    return defaultValue ?? [];
  }

  return gameTemplateDifficulty
      .map((e) => gameTemplateDifficultyFromJson(e.toString()))
      .toList();
}

List<enums.GameTemplateDifficulty>? gameTemplateDifficultyNullableListFromJson(
  List? gameTemplateDifficulty, [
  List<enums.GameTemplateDifficulty>? defaultValue,
]) {
  if (gameTemplateDifficulty == null) {
    return defaultValue;
  }

  return gameTemplateDifficulty
      .map((e) => gameTemplateDifficultyFromJson(e.toString()))
      .toList();
}

String? errorResponseDtoMessageNullableToJson(
    enums.ErrorResponseDtoMessage? errorResponseDtoMessage) {
  return errorResponseDtoMessage?.value;
}

String? errorResponseDtoMessageToJson(
    enums.ErrorResponseDtoMessage errorResponseDtoMessage) {
  return errorResponseDtoMessage.value;
}

enums.ErrorResponseDtoMessage errorResponseDtoMessageFromJson(
  Object? errorResponseDtoMessage, [
  enums.ErrorResponseDtoMessage? defaultValue,
]) {
  return enums.ErrorResponseDtoMessage.values
          .firstWhereOrNull((e) => e.value == errorResponseDtoMessage) ??
      defaultValue ??
      enums.ErrorResponseDtoMessage.swaggerGeneratedUnknown;
}

enums.ErrorResponseDtoMessage? errorResponseDtoMessageNullableFromJson(
  Object? errorResponseDtoMessage, [
  enums.ErrorResponseDtoMessage? defaultValue,
]) {
  if (errorResponseDtoMessage == null) {
    return null;
  }
  return enums.ErrorResponseDtoMessage.values
          .firstWhereOrNull((e) => e.value == errorResponseDtoMessage) ??
      defaultValue;
}

String errorResponseDtoMessageExplodedListToJson(
    List<enums.ErrorResponseDtoMessage>? errorResponseDtoMessage) {
  return errorResponseDtoMessage?.map((e) => e.value!).join(',') ?? '';
}

List<String> errorResponseDtoMessageListToJson(
    List<enums.ErrorResponseDtoMessage>? errorResponseDtoMessage) {
  if (errorResponseDtoMessage == null) {
    return [];
  }

  return errorResponseDtoMessage.map((e) => e.value!).toList();
}

List<enums.ErrorResponseDtoMessage> errorResponseDtoMessageListFromJson(
  List? errorResponseDtoMessage, [
  List<enums.ErrorResponseDtoMessage>? defaultValue,
]) {
  if (errorResponseDtoMessage == null) {
    return defaultValue ?? [];
  }

  return errorResponseDtoMessage
      .map((e) => errorResponseDtoMessageFromJson(e.toString()))
      .toList();
}

List<enums.ErrorResponseDtoMessage>?
    errorResponseDtoMessageNullableListFromJson(
  List? errorResponseDtoMessage, [
  List<enums.ErrorResponseDtoMessage>? defaultValue,
]) {
  if (errorResponseDtoMessage == null) {
    return defaultValue;
  }

  return errorResponseDtoMessage
      .map((e) => errorResponseDtoMessageFromJson(e.toString()))
      .toList();
}

String? serverCreateDiffResultDifficultyNullableToJson(
    enums.ServerCreateDiffResultDifficulty? serverCreateDiffResultDifficulty) {
  return serverCreateDiffResultDifficulty?.value;
}

String? serverCreateDiffResultDifficultyToJson(
    enums.ServerCreateDiffResultDifficulty serverCreateDiffResultDifficulty) {
  return serverCreateDiffResultDifficulty.value;
}

enums.ServerCreateDiffResultDifficulty serverCreateDiffResultDifficultyFromJson(
  Object? serverCreateDiffResultDifficulty, [
  enums.ServerCreateDiffResultDifficulty? defaultValue,
]) {
  return enums.ServerCreateDiffResultDifficulty.values.firstWhereOrNull(
          (e) => e.value == serverCreateDiffResultDifficulty) ??
      defaultValue ??
      enums.ServerCreateDiffResultDifficulty.swaggerGeneratedUnknown;
}

enums.ServerCreateDiffResultDifficulty?
    serverCreateDiffResultDifficultyNullableFromJson(
  Object? serverCreateDiffResultDifficulty, [
  enums.ServerCreateDiffResultDifficulty? defaultValue,
]) {
  if (serverCreateDiffResultDifficulty == null) {
    return null;
  }
  return enums.ServerCreateDiffResultDifficulty.values.firstWhereOrNull(
          (e) => e.value == serverCreateDiffResultDifficulty) ??
      defaultValue;
}

String serverCreateDiffResultDifficultyExplodedListToJson(
    List<enums.ServerCreateDiffResultDifficulty>?
        serverCreateDiffResultDifficulty) {
  return serverCreateDiffResultDifficulty?.map((e) => e.value!).join(',') ?? '';
}

List<String> serverCreateDiffResultDifficultyListToJson(
    List<enums.ServerCreateDiffResultDifficulty>?
        serverCreateDiffResultDifficulty) {
  if (serverCreateDiffResultDifficulty == null) {
    return [];
  }

  return serverCreateDiffResultDifficulty.map((e) => e.value!).toList();
}

List<enums.ServerCreateDiffResultDifficulty>
    serverCreateDiffResultDifficultyListFromJson(
  List? serverCreateDiffResultDifficulty, [
  List<enums.ServerCreateDiffResultDifficulty>? defaultValue,
]) {
  if (serverCreateDiffResultDifficulty == null) {
    return defaultValue ?? [];
  }

  return serverCreateDiffResultDifficulty
      .map((e) => serverCreateDiffResultDifficultyFromJson(e.toString()))
      .toList();
}

List<enums.ServerCreateDiffResultDifficulty>?
    serverCreateDiffResultDifficultyNullableListFromJson(
  List? serverCreateDiffResultDifficulty, [
  List<enums.ServerCreateDiffResultDifficulty>? defaultValue,
]) {
  if (serverCreateDiffResultDifficulty == null) {
    return defaultValue;
  }

  return serverCreateDiffResultDifficulty
      .map((e) => serverCreateDiffResultDifficultyFromJson(e.toString()))
      .toList();
}

String? receiveReplayDtoGameModeNullableToJson(
    enums.ReceiveReplayDtoGameMode? receiveReplayDtoGameMode) {
  return receiveReplayDtoGameMode?.value;
}

String? receiveReplayDtoGameModeToJson(
    enums.ReceiveReplayDtoGameMode receiveReplayDtoGameMode) {
  return receiveReplayDtoGameMode.value;
}

enums.ReceiveReplayDtoGameMode receiveReplayDtoGameModeFromJson(
  Object? receiveReplayDtoGameMode, [
  enums.ReceiveReplayDtoGameMode? defaultValue,
]) {
  return enums.ReceiveReplayDtoGameMode.values
          .firstWhereOrNull((e) => e.value == receiveReplayDtoGameMode) ??
      defaultValue ??
      enums.ReceiveReplayDtoGameMode.swaggerGeneratedUnknown;
}

enums.ReceiveReplayDtoGameMode? receiveReplayDtoGameModeNullableFromJson(
  Object? receiveReplayDtoGameMode, [
  enums.ReceiveReplayDtoGameMode? defaultValue,
]) {
  if (receiveReplayDtoGameMode == null) {
    return null;
  }
  return enums.ReceiveReplayDtoGameMode.values
          .firstWhereOrNull((e) => e.value == receiveReplayDtoGameMode) ??
      defaultValue;
}

String receiveReplayDtoGameModeExplodedListToJson(
    List<enums.ReceiveReplayDtoGameMode>? receiveReplayDtoGameMode) {
  return receiveReplayDtoGameMode?.map((e) => e.value!).join(',') ?? '';
}

List<String> receiveReplayDtoGameModeListToJson(
    List<enums.ReceiveReplayDtoGameMode>? receiveReplayDtoGameMode) {
  if (receiveReplayDtoGameMode == null) {
    return [];
  }

  return receiveReplayDtoGameMode.map((e) => e.value!).toList();
}

List<enums.ReceiveReplayDtoGameMode> receiveReplayDtoGameModeListFromJson(
  List? receiveReplayDtoGameMode, [
  List<enums.ReceiveReplayDtoGameMode>? defaultValue,
]) {
  if (receiveReplayDtoGameMode == null) {
    return defaultValue ?? [];
  }

  return receiveReplayDtoGameMode
      .map((e) => receiveReplayDtoGameModeFromJson(e.toString()))
      .toList();
}

List<enums.ReceiveReplayDtoGameMode>?
    receiveReplayDtoGameModeNullableListFromJson(
  List? receiveReplayDtoGameMode, [
  List<enums.ReceiveReplayDtoGameMode>? defaultValue,
]) {
  if (receiveReplayDtoGameMode == null) {
    return defaultValue;
  }

  return receiveReplayDtoGameMode
      .map((e) => receiveReplayDtoGameModeFromJson(e.toString()))
      .toList();
}

String? sendReplayDtoGameModeNullableToJson(
    enums.SendReplayDtoGameMode? sendReplayDtoGameMode) {
  return sendReplayDtoGameMode?.value;
}

String? sendReplayDtoGameModeToJson(
    enums.SendReplayDtoGameMode sendReplayDtoGameMode) {
  return sendReplayDtoGameMode.value;
}

enums.SendReplayDtoGameMode sendReplayDtoGameModeFromJson(
  Object? sendReplayDtoGameMode, [
  enums.SendReplayDtoGameMode? defaultValue,
]) {
  return enums.SendReplayDtoGameMode.values
          .firstWhereOrNull((e) => e.value == sendReplayDtoGameMode) ??
      defaultValue ??
      enums.SendReplayDtoGameMode.swaggerGeneratedUnknown;
}

enums.SendReplayDtoGameMode? sendReplayDtoGameModeNullableFromJson(
  Object? sendReplayDtoGameMode, [
  enums.SendReplayDtoGameMode? defaultValue,
]) {
  if (sendReplayDtoGameMode == null) {
    return null;
  }
  return enums.SendReplayDtoGameMode.values
          .firstWhereOrNull((e) => e.value == sendReplayDtoGameMode) ??
      defaultValue;
}

String sendReplayDtoGameModeExplodedListToJson(
    List<enums.SendReplayDtoGameMode>? sendReplayDtoGameMode) {
  return sendReplayDtoGameMode?.map((e) => e.value!).join(',') ?? '';
}

List<String> sendReplayDtoGameModeListToJson(
    List<enums.SendReplayDtoGameMode>? sendReplayDtoGameMode) {
  if (sendReplayDtoGameMode == null) {
    return [];
  }

  return sendReplayDtoGameMode.map((e) => e.value!).toList();
}

List<enums.SendReplayDtoGameMode> sendReplayDtoGameModeListFromJson(
  List? sendReplayDtoGameMode, [
  List<enums.SendReplayDtoGameMode>? defaultValue,
]) {
  if (sendReplayDtoGameMode == null) {
    return defaultValue ?? [];
  }

  return sendReplayDtoGameMode
      .map((e) => sendReplayDtoGameModeFromJson(e.toString()))
      .toList();
}

List<enums.SendReplayDtoGameMode>? sendReplayDtoGameModeNullableListFromJson(
  List? sendReplayDtoGameMode, [
  List<enums.SendReplayDtoGameMode>? defaultValue,
]) {
  if (sendReplayDtoGameMode == null) {
    return defaultValue;
  }

  return sendReplayDtoGameMode
      .map((e) => sendReplayDtoGameModeFromJson(e.toString()))
      .toList();
}

String? historyGameModeNullableToJson(enums.HistoryGameMode? historyGameMode) {
  return historyGameMode?.value;
}

String? historyGameModeToJson(enums.HistoryGameMode historyGameMode) {
  return historyGameMode.value;
}

enums.HistoryGameMode historyGameModeFromJson(
  Object? historyGameMode, [
  enums.HistoryGameMode? defaultValue,
]) {
  return enums.HistoryGameMode.values
          .firstWhereOrNull((e) => e.value == historyGameMode) ??
      defaultValue ??
      enums.HistoryGameMode.swaggerGeneratedUnknown;
}

enums.HistoryGameMode? historyGameModeNullableFromJson(
  Object? historyGameMode, [
  enums.HistoryGameMode? defaultValue,
]) {
  if (historyGameMode == null) {
    return null;
  }
  return enums.HistoryGameMode.values
          .firstWhereOrNull((e) => e.value == historyGameMode) ??
      defaultValue;
}

String historyGameModeExplodedListToJson(
    List<enums.HistoryGameMode>? historyGameMode) {
  return historyGameMode?.map((e) => e.value!).join(',') ?? '';
}

List<String> historyGameModeListToJson(
    List<enums.HistoryGameMode>? historyGameMode) {
  if (historyGameMode == null) {
    return [];
  }

  return historyGameMode.map((e) => e.value!).toList();
}

List<enums.HistoryGameMode> historyGameModeListFromJson(
  List? historyGameMode, [
  List<enums.HistoryGameMode>? defaultValue,
]) {
  if (historyGameMode == null) {
    return defaultValue ?? [];
  }

  return historyGameMode
      .map((e) => historyGameModeFromJson(e.toString()))
      .toList();
}

List<enums.HistoryGameMode>? historyGameModeNullableListFromJson(
  List? historyGameMode, [
  List<enums.HistoryGameMode>? defaultValue,
]) {
  if (historyGameMode == null) {
    return defaultValue;
  }

  return historyGameMode
      .map((e) => historyGameModeFromJson(e.toString()))
      .toList();
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
      chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
