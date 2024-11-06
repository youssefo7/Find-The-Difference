import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/generated/api.enums.swagger.dart';
import 'package:mobile/generated/api.swagger.dart';

String gameModeToString(BuildContext context, HistoryGameMode gameMode) {
  switch (gameMode) {
    case HistoryGameMode.classicmultiplayer:
      return AppLocalizations.of(context)!.classicMultiplayer;
    case HistoryGameMode.teamclassic:
      return AppLocalizations.of(context)!.teamClassic;
    case HistoryGameMode.timelimitsinglediff:
      return AppLocalizations.of(context)!.timeLimitSingleDiff;
    case HistoryGameMode.timelimitaugmented:
      return AppLocalizations.of(context)!.timeLimitAugmented;
    case HistoryGameMode.timelimitturnbyturn:
      return AppLocalizations.of(context)!.timeLimitTurnByTurn;
    default:
      return AppLocalizations.of(context)!.unknown;
  }
}

HistoryGameMode historyGameModeFromString(String? value) {
  for (final v in HistoryGameMode.values) {
    if (v.value == value) {
      return v;
    }
  }

  return HistoryGameMode.swaggerGeneratedUnknown;
}

ReceiveReplayDtoGameMode receiveReplayDtoGameModeFromString(String? value) {
  for (final v in ReceiveReplayDtoGameMode.values) {
    if (v.value == value) {
      return v;
    }
  }

  return ReceiveReplayDtoGameMode.swaggerGeneratedUnknown;
}

SendReplayDtoGameMode sendReplayDtoGameModeFromString(String? value) {
  for (final v in SendReplayDtoGameMode.values) {
    if (v.value == value) {
      return v;
    }
  }

  return SendReplayDtoGameMode.swaggerGeneratedUnknown;
}

bool isTimeLimit(HistoryGameMode gameMode) {
  final timeLimitModes = [
    HistoryGameMode.timelimitaugmented,
    HistoryGameMode.timelimitsinglediff,
    HistoryGameMode.timelimitturnbyturn,
  ];
  return timeLimitModes.contains(gameMode);
}
