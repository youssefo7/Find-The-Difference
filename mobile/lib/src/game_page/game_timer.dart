import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({super.key});

  @override
  GameTimerState createState() => GameTimerState();
}

class GameTimerState extends State<GameTimer> {
  final _socketIoService = GetIt.I.get<SocketIoService>();
  int _gameTime = 0;
  int? _team2Time;

  @override
  void initState() {
    super.initState();
    _socketIoService.on(GameManagerEvent.timeEvent, _onTimeUpdate);
  }

  @override
  void dispose() {
    _socketIoService.off(GameManagerEvent.timeEvent, _onTimeUpdate);
    super.dispose();
  }

  void _onTimeUpdate(dynamic timeEventJson) {
    TimeEventDto timeEventDto = TimeEventDto.fromJson(timeEventJson);
    setState(() {
      _gameTime = timeEventDto.timeMs ~/ 1000;
      _team2Time = timeEventDto.team2TimeMs != null
          ? timeEventDto.team2TimeMs! ~/ 1000
          : null;
    });
  }

  String _formatTime(int? seconds) {
    if (seconds == null) return '00:00';
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTimerBox(_gameTime),
        if (_team2Time != null) _buildTimerBox(_team2Time!),
      ],
    );
  }

  Widget _buildTimerBox(int time) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 34),
            const SizedBox(width: 4),
            Text(_formatTime(time), style: const TextStyle(fontSize: 28)),
          ],
        ),
      ),
    );
  }
}
