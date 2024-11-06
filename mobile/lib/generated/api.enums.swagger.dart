import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum GameTemplateDifficulty {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('easy')
  easy('easy'),
  @JsonValue('hard')
  hard('hard');

  final String? value;

  const GameTemplateDifficulty(this.value);
}

enum ErrorResponseDtoMessage {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('Missing or bad JWT')
  missingOrBadJwt('Missing or bad JWT'),
  @JsonValue('Cannot Rename Admin')
  cannotRenameAdmin('Cannot Rename Admin'),
  @JsonValue('User already connected')
  userAlreadyConnected('User already connected'),
  @JsonValue('User does not exist')
  userDoesNotExist('User does not exist'),
  @JsonValue('User already exists')
  userAlreadyExists('User already exists'),
  @JsonValue('Password is invalid')
  passwordIsInvalid('Password is invalid'),
  @JsonValue('Game template not found')
  gameTemplateNotFound('Game template not found'),
  @JsonValue('Invalid page number, should be greater or equal to zero')
  invalidPageNumberShouldBeGreaterOrEqualToZero(
      'Invalid page number, should be greater or equal to zero'),
  @JsonValue('Invalid ObjectId')
  invalidObjectid('Invalid ObjectId'),
  @JsonValue('The base64 encoded images should be in bmp, jpg or png format')
  theBase64EncodedImagesShouldBeInBmpJpgOrPngFormat(
      'The base64 encoded images should be in bmp, jpg or png format'),
  @JsonValue('Image not found')
  imageNotFound('Image not found'),
  @JsonValue('Dto contains invalid field')
  dtoContainsInvalidField('Dto contains invalid field'),
  @JsonValue('Not enough money')
  notEnoughMoney('Not enough money');

  final String? value;

  const ErrorResponseDtoMessage(this.value);
}

enum ServerCreateDiffResultDifficulty {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('easy')
  easy('easy'),
  @JsonValue('hard')
  hard('hard');

  final String? value;

  const ServerCreateDiffResultDifficulty(this.value);
}

enum ReceiveReplayDtoGameMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('teamClassic')
  teamclassic('teamClassic'),
  @JsonValue('timeLimitSingleDiff')
  timelimitsinglediff('timeLimitSingleDiff'),
  @JsonValue('timeLimitAugmented')
  timelimitaugmented('timeLimitAugmented'),
  @JsonValue('timeLimitTurnByTurn')
  timelimitturnbyturn('timeLimitTurnByTurn'),
  @JsonValue('classicMultiplayer')
  classicmultiplayer('classicMultiplayer');

  final String? value;

  const ReceiveReplayDtoGameMode(this.value);
}

enum SendReplayDtoGameMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('teamClassic')
  teamclassic('teamClassic'),
  @JsonValue('timeLimitSingleDiff')
  timelimitsinglediff('timeLimitSingleDiff'),
  @JsonValue('timeLimitAugmented')
  timelimitaugmented('timeLimitAugmented'),
  @JsonValue('timeLimitTurnByTurn')
  timelimitturnbyturn('timeLimitTurnByTurn'),
  @JsonValue('classicMultiplayer')
  classicmultiplayer('classicMultiplayer');

  final String? value;

  const SendReplayDtoGameMode(this.value);
}

enum HistoryGameMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('teamClassic')
  teamclassic('teamClassic'),
  @JsonValue('timeLimitSingleDiff')
  timelimitsinglediff('timeLimitSingleDiff'),
  @JsonValue('timeLimitAugmented')
  timelimitaugmented('timeLimitAugmented'),
  @JsonValue('timeLimitTurnByTurn')
  timelimitturnbyturn('timeLimitTurnByTurn'),
  @JsonValue('classicMultiplayer')
  classicmultiplayer('classicMultiplayer');

  final String? value;

  const HistoryGameMode(this.value);
}
