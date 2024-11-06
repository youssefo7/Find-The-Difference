import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/game_page/blink_service.dart';
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/services/socket_io_service.dart';

const possibleReplaySpeeds = [1, 2, 4];
const framesPerSecond = 60;

const inGameEvents = [
  GameManagerEvent.startGame,
  GameManagerEvent.endGame,
  GameManagerEvent.differenceFound,
  GameManagerEvent.differenceNotFound,
  GameManagerEvent.showError,
  GameManagerEvent.removePixels,
  GameManagerEvent.timeEvent,
  GameManagerEvent.playerLeave,
  GameManagerEvent.receiveHint,
  GameManagerEvent.observerJoinedEvent,
  GameManagerEvent.observerLeavedEvent,
];

class ReplayService with ChangeNotifier {
  bool isReplaying = false;
  int currentReplaySpeed = possibleReplaySpeeds[0];

  List<ReplayEvent> _events = [];
  int _nextEventIndex = 1;
  double _replayTimestamp = 0;
  Timer? _timer;

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();
  ImageController get _imageController => GetIt.I.get<ImageController>();

  double get duration {
    return _events.last.time - _events.first.time;
  }

  double get currentFraction {
    return _replayTimestamp / duration;
  }

  bool get isInReplayMode {
    return _events.isNotEmpty;
  }

  void setFraction(double fraction) {
    stopPlayback();
    _replayTimestamp = fraction * duration;
    notifyListeners();
  }

  void recalculateFromKeyFrame() {
    _nextEventIndex = 1;
    final event = _events.first;
    _socketIoService.fakeOn(event.name, event.data);
    _replayUntilTimestamp();
  }

  void uninitialize() {
    _timer?.cancel();
    _events.clear();

    _imageController.uninitialize();
  }

  bool isAtEndOfReplay() {
    return _nextEventIndex + 1 >= _events.length;
  }

  void startPlayback() {
    if (isReplaying) return;
    isReplaying = true;

    _timer = Timer.periodic(
        const Duration(milliseconds: msPerSecond ~/ framesPerSecond), (timer) {
      _onFrameUpdate();
    });
    notifyListeners();
  }

  void stopPlayback() {
    if (!isReplaying) return;
    isReplaying = false;
    _timer?.cancel();
    notifyListeners();
  }

  void togglePlayback() {
    if (isReplaying) {
      stopPlayback();
    } else {
      startPlayback();
    }
  }

  loadReplay(ReceiveReplayDto replayDto) {
    isReplaying = false;
    currentReplaySpeed = possibleReplaySpeeds[0];
    _nextEventIndex = 1;
    _events = replayDto.events;
    setFraction(0);

    Timer(const Duration(seconds: 1), () => _imageController.initialize());

    final event = _events.first;
    _socketIoService.fakeOn(event.name, event.data);
  }

  Timer periodicTimer(Duration duration, void Function(Timer) callback) {
    final d =
        Duration(milliseconds: duration.inMilliseconds ~/ currentReplaySpeed);
    return Timer.periodic(d, (timer) {
      if (!isInReplayMode || isReplaying) {
        callback(timer);
      }
    });
  }

  Timer timer(Duration duration, void Function() callback) {
    final d =
        Duration(milliseconds: duration.inMilliseconds ~/ currentReplaySpeed);
    return Timer(d, callback);
  }

  void _onFrameUpdate() {
    _replayTimestamp += msPerSecond ~/ framesPerSecond * currentReplaySpeed;
    _replayUntilTimestamp();
  }

  void _replayUntilTimestamp() {
    var event = _events[_nextEventIndex];

    while (event.time <= _replayTimestamp + _events.first.time) {
      if (isAtEndOfReplay() || event.name == GameManagerEvent.endGame.name) {
        stopPlayback();
        break;
      }

      _socketIoService.fakeOn(event.name, event.data);
      _nextEventIndex++;

      if (_nextEventIndex >= _events.length) {
        stopPlayback();
        break;
      }
      event = _events[_nextEventIndex];
    }

    notifyListeners();
  }
}
