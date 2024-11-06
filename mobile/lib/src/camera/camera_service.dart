import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/src/services/log_service.dart';

class CameraService {
  late List<CameraDescription> _cameras;
  late CameraDescription _frontCamera;
  late CameraDescription _backCamera;

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    _cameras = await availableCameras();
    _frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _backCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
  }

  get frontCameraController => CameraController(
        _frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

  get backCameraController => CameraController(
        _backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

  Future<String> formatImageToBase64(XFile image, int size, bool flip) async {
    img.Image? capturedImage = img.decodeImage(await image.readAsBytes());
    if (capturedImage == null) {
      GetIt.I.get<LogService>().error('Failed to decode image');
      return '';
    }

    if (flip) {
      // flip the image horizontally
      capturedImage = img.flipHorizontal(capturedImage);
    }

    // crop the image
    final img.Image croppedImage = _cropImage(capturedImage);

    // resize the image
    final img.Image resizedImage = _resizeImage(croppedImage, size);

    return base64Encode(img.encodePng(resizedImage));
  }

  img.Image _resizeImage(img.Image image, int size) {
    return img.copyResize(image,
        width: size, height: size, interpolation: img.Interpolation.cubic);
  }

  img.Image _cropImage(img.Image image) {
    final int cropSize =
        image.width < image.height ? image.width : image.height;
    return img.copyCrop(
      image,
      x: (image.width - cropSize) ~/ 2,
      y: (image.height - cropSize) ~/ 2,
      width: cropSize,
      height: cropSize,
    );
  }
}
