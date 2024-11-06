import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/services/log_service.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIoService {
  final _baseUrl = const String.fromEnvironment('WS_URL');
  final Duration _connectionTimeout = const Duration(seconds: 5);

  get isConnected => _socket != null && _socket!.connected;

  IO.Socket? _socket;
  final Map<String, List<void Function(dynamic)>> _events = {};

  Future<bool> connect(String token, dynamic Function() disconnectCallback) {
    if (token.isEmpty) {
      return Future.value(false);
    }
    if (_socket != null && _socket!.connected) {
      return Future.value(true);
    }

    _socket = IO.io(
        _baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
            })
            .disableReconnection()
            .enableForceNew()
            .build());

    Completer<bool> connectCompleter = Completer();
    _listenOnConnect(connectCompleter);
    _listenOnException();
    _listenOnDisconnect(disconnectCallback);
    _socket!.connect();

    _socket!.onAny((event, data) {
      String dataStr = data.toString();
      dataStr = dataStr.substring(0, min(dataStr.length, 100));
      GetIt.I.get<LogService>().debug('WS event \'$event\': $dataStr');
    });

    return Future.any([
      connectCompleter.future,
      Future.delayed(_connectionTimeout, () => false)
    ]);
  }

  void disconnect() {
    if (_socket == null) return;
    _socket!.dispose();
    _socket = null;
  }

  void on(GameManagerEvent event, void Function(dynamic) callback) {
    _socket?.on(event.name, callback);
    _events.putIfAbsent(event.name, () => []);
    _events[event.name]!.add(callback);
  }

  void fakeOn(String event, dynamic dto) {
    GetIt.I.get<LogService>().info('fakeOn $event ${_events[event]}');
    _events[event]?.forEach((callback) => callback(dto));
  }

  void emit(GameManagerEvent event, dynamic data) {
    GetIt.I.get<LogService>().info('WS emit \'${event.name}\': $data');
    _socket?.emit(event.name, data);
  }

  void off(GameManagerEvent event, [void Function(dynamic)? handler]) {
    _socket?.off(event.name, handler);
    if (handler == null) {
      _events.remove(event.name);
    } else {
      _events.update(event.name, (value) {
        value.remove(handler);
        return value;
      });
    }
  }

  void onJoinRequests(void Function(JoinRequestsDto) callback) {
    on(GameManagerEvent.joinRequests, (dto) {
      callback(JoinRequestsDto.fromJson(dto));
    });
  }

  void onStartGame(void Function(StartGameDto) callback) {
    on(GameManagerEvent.startGame, (dto) {
      callback(StartGameDto.fromJson(dto));
    });
  }

  void onWaitingRefusal(void Function() callback) {
    on(GameManagerEvent.waitingRefusal, (dto) {
      callback();
    });
  }

  void onAssignGameMaster(void Function() callback) {
    on(GameManagerEvent.assignGameMaster, (dto) {
      callback();
    });
  }

  void onInstanceDeletion(void Function() callback) {
    on(GameManagerEvent.onInstanceDeletion, (dto) {
      callback();
    });
  }

  void onInvalidStartingState(void Function() callback) {
    on(GameManagerEvent.invalidStartingState, (dto) {
      callback();
    });
  }

  void onWaitingGames(void Function(WaitingGamesListDto) callback) {
    on(GameManagerEvent.waitingGames, (dto) {
      callback(WaitingGamesListDto.fromJson(dto));
    });
  }

  void onDifferenceFound(void Function(DifferenceFoundDto) callback) {
    on(GameManagerEvent.differenceFound, (dto) {
      callback(DifferenceFoundDto.fromJson(dto));
    });
  }

  void onDifferenceNotFound(void Function(DifferenceNotFoundDto) callback) {
    on(GameManagerEvent.differenceNotFound, (dto) {
      callback(DifferenceNotFoundDto.fromJson(dto));
    });
  }

  void onRemovePixels(void Function(RemovePixelsDto) callback) {
    on(GameManagerEvent.removePixels, (dto) {
      callback(RemovePixelsDto.fromJson(dto));
    });
  }

  void onEndGame(void Function(EndGameDto) callback) {
    on(GameManagerEvent.endGame, (dto) {
      callback(EndGameDto.fromJson(dto));
    });
  }

  void onChangeTemplate(void Function(ChangeTemplateDto) callback) {
    on(GameManagerEvent.changeTemplate, (dto) {
      callback(ChangeTemplateDto.fromJson(dto));
    });
  }

  void onShowError(void Function(ShowErrorDto) callback) {
    on(GameManagerEvent.showError, (dto) {
      callback(ShowErrorDto.fromJson(dto));
    });
  }

  void onUpdateBalance(void Function(UpdateBalanceDto) callback) {
    on(GameManagerEvent.updateBalance, (dto) {
      callback(UpdateBalanceDto.fromJson(dto));
    });
  }

  void onCheatModeEvent(void Function(CheatModeDto) callback) {
    on(GameManagerEvent.cheatModeEvent, (dto) {
      callback(CheatModeDto.fromJson(dto));
    });
  }

  void onObserverStateSync(void Function(StateDto) callback) {
    on(GameManagerEvent.observerStateSync, (dto) {
      callback(StateDto.fromJson(dto));
    });
  }

  void onReceiveHint(void Function(ReceiveHintDto) callback) {
    on(GameManagerEvent.receiveHint, (dto) {
      callback(ReceiveHintDto.fromJson(dto));
    });
  }

  void _listenOnConnect(Completer<bool> connectCompleter) {
    _socket?.on('connect', (_) {
      GetIt.I.get<LogService>().info('WS event \'connect\'');
      connectCompleter.complete(true);
    });
  }

  void _listenOnException() {
    _socket?.on('exception', (error) {
      GetIt.I.get<LogService>().error('WS event \'exception\' : $error');
    });
  }

  void _listenOnDisconnect(dynamic Function() callback) {
    _socket?.on('disconnect', (_) {
      GetIt.I.get<LogService>().info('WS event \'disconnect\'');
      callback();
    });
  }
}
