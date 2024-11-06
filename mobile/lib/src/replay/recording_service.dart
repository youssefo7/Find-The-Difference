import 'package:get_it/get_it.dart';
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/services/socket_io_service.dart';

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

class RecordingService {
  final List<ReplayEvent> _events = [];

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();

  List<ReplayEvent> get events => _events;

  void initialize() {
    _events.clear();

    for (var event in inGameEvents) {
      _socketIoService.on(event, (dto) {
        _saveReceivedEvent(event.name, dto);
      });
    }

    _socketIoService.onEndGame((endGameDto) {
      dispose();
    });
  }

  void dispose() {
    for (var event in inGameEvents) {
      _socketIoService.off(event);
    }
  }

  void _saveReceivedEvent(String eventName, dynamic data) {
    if (eventName == GameManagerEvent.cheatModeEvent.name) {
      return;
    }
    _events.add(ReplayEvent(
      name: eventName,
      time: _now().toDouble(),
      data: data,
    ));
  }

  int _now() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
