# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple).

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter
apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

## Environments

### Development on Windows

```json
{
    "SERVER_URL": "http://localhost:3000/api",
    "WS_URL": "ws://localhost:3000"
}
```

### Development on Android Emulator

```json
{
    "SERVER_URL": "http://10.0.2.2:3000/api",
    "WS_URL": "ws://10.0.2.2:3000"
}
```

### Production

```json
{
    "SERVER_URL": "https://server.leobc.top/api",
    "WS_URL": "wss://server.leobc.top"
}
```

## CLI

### Run on Windows

```bash
flutter run -d windows --dart-define=SERVER_URL=http://localhost:3000/api --dart-define=WS_URL=ws://localhost:3000
```

### Run on android emulator

```bash
flutter run -d emulator-5554 --dart-define=SERVER_URL=http://10.0.2.2:3000/api --dart-define=WS_URL=ws://10.0.2.2:3000
```

### Build

```bash
flutter build apk --dart-define=SERVER_URL=https://server.leobc.top/api --dart-define=WS_URL=wss://server.leobc.top
```

## swagger dart code generator

### Generate the code

```bash
# make sure that the server is running locally on port 3000
curl http://localhost:3000/api/docs-json -o lib/swagger/api.json
rm -r lib/generated
dart run build_runner build
```

```pwsh
# make sure that the server is running locally on port 3000
Invoke-WebRequest -Uri http://localhost:3000/api/docs-json -OutFile lib/swagger/api.json
Remove-Item lib/generated -Recurse
dart run build_runner build
```

## Socket IO code generator

```sh
# this generates the following files:
# mobile/lib/src/models/game_manager_event.dart
# mobile/lib/src/models/socket_io_events.dart
python tools/game-manager-to-dart.py
cd mobile
dart run build_runner build
dart format lib
```

## Lint and format

dart analyze --fatal-infos
dart format lib

## Update mobile

```pwsh
Invoke-WebRequest -Uri http://localhost:3000/api/docs-json -OutFile lib/swagger/api.json
Remove-Item lib/generated -Recurse
dart run build_runner build
python ../tools/game-manager-to-dart.py
dart run build_runner build
dart format lib
```
