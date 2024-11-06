import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/generated/api.swagger.dart';
import 'package:mobile/src/game_page/blink_service.dart';
import 'package:mobile/src/models/game_manager_event.dart';
import 'package:mobile/src/models/game_template.dart';
import 'package:mobile/src/models/socket_io_events.dart';
import 'package:mobile/src/services/bucket_service.dart';
import 'package:mobile/src/services/socket_io_service.dart';

class ImageController extends ChangeNotifier {
  img.Image? _firstImage;
  img.Image? _secondImage;

  Future<(img.Image, img.Image)>? _nextImages;

  SocketIoService get _socketIoService => GetIt.I.get<SocketIoService>();
  BucketService get _bucketService => GetIt.I.get<BucketService>();

  late BlinkService _blinkService;

  void initialize() {
    _listenOnRemovePixels();
    _listenOnChangeTemplate();
    _listenOnCheatModeEvent();
    _socketIoService.onEndGame(_onEndGame);

    _blinkService = BlinkService((img1, img2) {
      _firstImage = img1;
      _secondImage = img2;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    uninitialize();
  }

  void uninitialize() {
    _socketIoService.off(GameManagerEvent.removePixels);
    _socketIoService.off(GameManagerEvent.changeTemplate);
    _socketIoService.off(GameManagerEvent.cheatModeEvent);
    _socketIoService.off(GameManagerEvent.endGame);
  }

  void toggleCheatMode() {
    if (_blinkService.isCheatModeBlinking) {
      _blinkService.disableCheatModeBlink();
    } else {
      _socketIoService.emit(GameManagerEvent.cheatModeEvent, null);
    }
  }

  Widget? getImage(ImageClicked side) {
    final image = getRawImage(side);
    if (image == null) {
      return null;
    }

    return Image.memory(
      img.encodeBmp(image),
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }

  img.Image? getRawImage(ImageClicked side) {
    return side == ImageClicked.left ? _firstImage : _secondImage;
  }

  void reset() {
    _firstImage = null;
    _secondImage = null;
    _nextImages = null;
    _blinkService.disableCheatModeBlink();
  }

  void precacheGameTemplate(
      BuildContext context, GameTemplate gameTemplate) async {
    if (gameTemplate.firstImage == '' || gameTemplate.secondImage == '') {
      return;
    }

    final img1 = await _loadNetworkImage(
        _bucketService.getFullUrl(gameTemplate.firstImage));
    final img2 = await _loadNetworkImage(
        _bucketService.getFullUrl(gameTemplate.secondImage));

    _firstImage = img.decodePng(img1!);
    _secondImage = img.decodePng(img2!);
    notifyListeners();
  }

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var i = NetworkImage(path);
    i.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    final byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<(img.Image, img.Image)> _loadNextImages(
      ChangeTemplateDto changeTemplateDto) async {
    final response = await GetIt.I
        .get<Api>()
        .apiGameTemplateIdGet(id: changeTemplateDto.nextGameTemplateId);
    final gameTemplate = response.body!;

    final networkImage1 = await _loadNetworkImage(
        _bucketService.getFullUrl(gameTemplate.firstImage));
    final networkImage2 = await _loadNetworkImage(
        _bucketService.getFullUrl(gameTemplate.secondImage));

    final img1 = img.decodePng(networkImage1!)!;
    final img2 = img.decodePng(networkImage2!)!;

    if (changeTemplateDto.pixelsToRemove != null) {
      for (var pixel in changeTemplateDto.pixelsToRemove!) {
        final p = img1.getPixel(pixel.x, pixel.y);
        img2.setPixel(pixel.x, pixel.y, p);
      }
    }

    return (img1, img2);
  }

  void _listenOnRemovePixels() {
    _socketIoService.onRemovePixels((removePixelsDto) {
      _blinkService.blinkPixelsAndRemove(removePixelsDto.pixels);
    });
  }

  void _listenOnChangeTemplate() {
    _socketIoService.onChangeTemplate((data) => onChangeTemplate(data));
  }

  void onChangeTemplate(changeTemplateDto) {
    if (_nextImages != null) {
      _blinkService.blinkEndCallback();
      _nextImages?.then((t) {
        if (_blinkService.isCheatModeBlinking) {
          toggleCheatMode();
          toggleCheatMode();
        }

        _firstImage = t.$1;
        _secondImage = t.$2;
        notifyListeners();
      });
    }

    if (changeTemplateDto.nextGameTemplateId != null) {
      _nextImages = _loadNextImages(changeTemplateDto);
    }
  }

  void _listenOnCheatModeEvent() {
    _socketIoService.onCheatModeEvent((cheatModeDto) {
      _blinkService.enableCheatModeBlink(
          cheatModeDto.groupToPixels.expand((e) => e).toList());
    });
  }

  void _onEndGame(EndGameDto endGameDto) {
    _blinkService.disableCheatModeBlink();
  }

  void updateGameState(List<Vec2> pixelsToRemove) {
    for (var pixel in pixelsToRemove) {
      final p = _firstImage?.getPixel(pixel.x, pixel.y);
      _secondImage?.setPixel(pixel.x, pixel.y, p!);
    }
  }
}
