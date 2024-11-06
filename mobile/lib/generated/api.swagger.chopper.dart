// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$Api extends Api {
  _$Api([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = Api;

  @override
  Future<Response<List<GameTemplate>>> _apiGameTemplateGet() {
    final Uri $url = Uri.parse('/api/game-template');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<GameTemplate>, GameTemplate>($request);
  }

  @override
  Future<Response<dynamic>> _apiGameTemplatePost(
      {required ServerCreateGameDto? body}) {
    final Uri $url = Uri.parse('/api/game-template');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiGameTemplateDelete() {
    final Uri $url = Uri.parse('/api/game-template');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<num>> _apiGameTemplateLengthGet() {
    final Uri $url = Uri.parse('/api/game-template/length');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<num, num>($request);
  }

  @override
  Future<Response<GameTemplate>> _apiGameTemplateIdGet({required String? id}) {
    final Uri $url = Uri.parse('/api/game-template/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<GameTemplate, GameTemplate>($request);
  }

  @override
  Future<Response<dynamic>> _apiGameTemplateIdDelete({required String? id}) {
    final Uri $url = Uri.parse('/api/game-template/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<GameTemplate>>> _apiGameTemplatePagePageGet(
      {required String? page}) {
    final Uri $url = Uri.parse('/api/game-template/page/${page}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<GameTemplate>, GameTemplate>($request);
  }

  @override
  Future<Response<ServerCreateDiffResult>> _apiImagesDifferencesPost(
      {required CreateImagesDifferencesDto? body}) {
    final Uri $url = Uri.parse('/api/images-differences');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<ServerCreateDiffResult, ServerCreateDiffResult>($request);
  }

  @override
  Future<Response<JwtTokenDto>> _apiAuthLoginPost({required LoginDto? body}) {
    final Uri $url = Uri.parse('/api/auth/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<JwtTokenDto, JwtTokenDto>($request);
  }

  @override
  Future<Response<JwtTokenDto>> _apiAuthRegisterPost(
      {required CreateUserDto? body}) {
    final Uri $url = Uri.parse('/api/auth/register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<JwtTokenDto, JwtTokenDto>($request);
  }

  @override
  Future<Response<JwtTokenDto>> _apiAuthRefreshJwtGet() {
    final Uri $url = Uri.parse('/api/auth/refresh-jwt');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<JwtTokenDto, JwtTokenDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiAuthChangePasswordPost(
      {required ChangePasswordDto? body}) {
    final Uri $url = Uri.parse('/api/auth/changePassword');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Object>>> _apiUserGet() {
    final Uri $url = Uri.parse('/api/user');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Object>, Object>($request);
  }

  @override
  Future<Response<UserDto>> _apiUserProfileGet() {
    final Uri $url = Uri.parse('/api/user/profile');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UserDto, UserDto>($request);
  }

  @override
  Future<Response<Theme>> _apiUserThemeGet() {
    final Uri $url = Uri.parse('/api/user/theme');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Theme, Theme>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserThemePatch({required Theme? body}) {
    final Uri $url = Uri.parse('/api/user/theme');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<num>>> _apiUserStatsUsernameGet(
      {required String? username}) {
    final Uri $url = Uri.parse('/api/user/stats/${username}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<num>, num>($request);
  }

  @override
  Future<Response<num>> _apiUserBalanceGet() {
    final Uri $url = Uri.parse('/api/user/balance');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<num, num>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserStatsPatch(
      {required DifferenceFoundRatioDto? body}) {
    final Uri $url = Uri.parse('/api/user/stats');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<ReceiveReplayDto>>> _apiUserReplaysGet() {
    final Uri $url = Uri.parse('/api/user/replays');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<ReceiveReplayDto>, ReceiveReplayDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserAddReplayPost(
      {required SendReplayDto? body}) {
    final Uri $url = Uri.parse('/api/user/addReplay');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserDeleteReplayReplayIdDelete(
      {required String? replayId}) {
    final Uri $url = Uri.parse('/api/user/deleteReplay/${replayId}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<LocaleDto>> _apiUserLocaleGet() {
    final Uri $url = Uri.parse('/api/user/locale');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<LocaleDto, LocaleDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserLocalePatch({required LocaleDto? body}) {
    final Uri $url = Uri.parse('/api/user/locale');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserUsernamePatch(
      {required UsernameDto? body}) {
    final Uri $url = Uri.parse('/api/user/username');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiUserChangeAvatarPatch(
      {required ChangeAvatarDto? body}) {
    final Uri $url = Uri.parse('/api/user/change-avatar');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<History>>> _apiHistoryGet() {
    final Uri $url = Uri.parse('/api/history');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<History>, History>($request);
  }

  @override
  Future<Response<dynamic>> _apiHistoryDelete() {
    final Uri $url = Uri.parse('/api/history');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<History>>> _apiHistoryUsernameGet(
      {required String? username}) {
    final Uri $url = Uri.parse('/api/history/${username}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<History>, History>($request);
  }

  @override
  Future<Response<List<ChatSchema>>> _apiChatAvailableChatsGet() {
    final Uri $url = Uri.parse('/api/chat/available-chats');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<ChatSchema>, ChatSchema>($request);
  }

  @override
  Future<Response<List<ChatIdSchema>>> _apiChatJoinedChatsGet() {
    final Uri $url = Uri.parse('/api/chat/joined-chats');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<ChatIdSchema>, ChatIdSchema>($request);
  }

  @override
  Future<Response<ChatIdSchema>> _apiChatGeneralChatIdGet() {
    final Uri $url = Uri.parse('/api/chat/general-chat-id');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ChatIdSchema, ChatIdSchema>($request);
  }

  @override
  Future<Response<List<String>>> _apiFriendsFriendListGet() {
    final Uri $url = Uri.parse('/api/friends/friend-list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiFriendsFriendListUsernameGet(
      {required String? username}) {
    final Uri $url = Uri.parse('/api/friends/friend-list/${username}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiFriendsOutgoingRequestListGet() {
    final Uri $url = Uri.parse('/api/friends/outgoing-request-list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiFriendsIncomingRequestListGet() {
    final Uri $url = Uri.parse('/api/friends/incoming-request-list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<AccountHistory>>> _apiAccountHistoryGet() {
    final Uri $url = Uri.parse('/api/account-history');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<AccountHistory>, AccountHistory>($request);
  }

  @override
  Future<Response<dynamic>> _apiAccountHistoryDelete() {
    final Uri $url = Uri.parse('/api/account-history');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<AccountHistory>>> _apiAccountHistoryUsernameGet(
      {required String? username}) {
    final Uri $url = Uri.parse('/api/account-history/${username}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<AccountHistory>, AccountHistory>($request);
  }

  @override
  Future<Response<dynamic>> _apiMarketBuyGamePost({required BuyGameDto? body}) {
    final Uri $url = Uri.parse('/api/market/buyGame');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<GameTemplate>>> _apiMarketBuyableGamesGet() {
    final Uri $url = Uri.parse('/api/market/buyableGames');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<GameTemplate>, GameTemplate>($request);
  }

  @override
  Future<Response<List<GameTemplate>>> _apiMarketAvailableGamesGet() {
    final Uri $url = Uri.parse('/api/market/availableGames');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<GameTemplate>, GameTemplate>($request);
  }
}
