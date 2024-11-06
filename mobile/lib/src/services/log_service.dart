class LogService {
  // All print call in this service may be replaced with a logger

  void log(String message) {
    _logWithColor(message, _Color.white);
  }

  void error(String message) {
    _logWithColor(message, _Color.red);
  }

  void warning(String message) {
    _logWithColor(message, _Color.yellow);
  }

  void success(String message) {
    _logWithColor(message, _Color.green);
  }

  void debug(String message) {
    _logWithColor(message, _Color.magenta);
  }

  void info(String message) {
    _logWithColor(message, _Color.cyan);
  }

  void _logWithColor(String message, _Color color) {
    final time = DateTime.now();
    // ignore: avoid_print
    print('\x1B[${color._value}m$time: $message\x1B[0m');
  }
}

enum _Color {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  reset,
}

extension _ColorExtension on _Color {
  String get _value {
    switch (this) {
      case _Color.black:
        return '30';
      case _Color.red:
        return '31';
      case _Color.green:
        return '32';
      case _Color.yellow:
        return '33';
      case _Color.blue:
        return '34';
      case _Color.magenta:
        return '35';
      case _Color.cyan:
        return '36';
      case _Color.white:
        return '37';
      case _Color.reset:
        return '0';
    }
  }
}
