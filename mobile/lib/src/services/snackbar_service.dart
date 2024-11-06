import 'package:flutter/material.dart';
import 'package:mobile/src/app.dart';

class SnackBarMessage {
  final String text;
  SnackBarMessage({required this.text});
}

class SnackBarService {
  final List<SnackBarMessage> _messageQueue = [];
  bool _isDisplaying = false;

  void enqueueSnackBar(String text) {
    _messageQueue.add(SnackBarMessage(text: text));
    _displayNext();
  }

  void _displayNext() {
    if (_isDisplaying ||
        _messageQueue.isEmpty ||
        scaffoldMessengerKey.currentState == null) {
      return;
    }

    _isDisplaying = true;
    final message = _messageQueue.removeAt(0);

    final snackBar = SnackBar(
      content: Text(message.text),
    );

    scaffoldMessengerKey.currentState!
        .showSnackBar(snackBar)
        .closed
        .then((reason) {
      _isDisplaying = false;
      _displayNext();
    });
  }
}
