import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/camera/camera_service.dart';
import 'package:mobile/src/services/log_service.dart';

class CameraPreviewDialog extends StatefulWidget {
  const CameraPreviewDialog({super.key, required this.previewSize});

  final double previewSize;

  @override
  State<CameraPreviewDialog> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreviewDialog> {
  CameraController _cameraController =
      GetIt.I.get<CameraService>().frontCameraController;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void switchCamera() async {
    await _cameraController.dispose();
    if (_cameraLensDirection == CameraLensDirection.front) {
      _cameraController = GetIt.I.get<CameraService>().backCameraController;
      _cameraLensDirection = CameraLensDirection.back;
    } else {
      _cameraController = GetIt.I.get<CameraService>().frontCameraController;
      _cameraLensDirection = CameraLensDirection.front;
    }
    await _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) _cameraController.dispose();
    super.dispose();
  }

  SizedBox get _cameraPreview => SizedBox(
      child: ClipOval(
          clipper: _CameraPreviewClipper(),
          child: CameraPreview(
            _cameraController,
          )));

  List<TextButton> get _actionButtons => [
        TextButton(
          onPressed: switchCamera,
          child: Text(AppLocalizations.of(context)!.switchCamera),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.close),
        ),
        TextButton(
          onPressed: () async {
            try {
              final file = await _cameraController.takePicture();
              final bool flipImage =
                  _cameraLensDirection == CameraLensDirection.front;
              final base64Image = await GetIt.I
                  .get<CameraService>()
                  .formatImageToBase64(
                      file, widget.previewSize.toInt(), flipImage);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(base64Image);
            } catch (e) {
              GetIt.I.get<LogService>().error('Error taking picture: $e');
            }
          },
          child: Text(AppLocalizations.of(context)!.takePicture),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.cameraPreview),
      content: _cameraController.value.isInitialized
          ? _cameraPreview
          : const SizedBox(),
      actions: _cameraController.value.isInitialized ? _actionButtons : [],
    );
  }
}

/// Custom clipper to create a circular clip
/// for the camera preview.
class _CameraPreviewClipper extends CustomClipper<Rect> {
  _CameraPreviewClipper();

  @override
  Rect getClip(Size size) {
    final minimumSize = size.width < size.height ? size.width : size.height;
    return Rect.fromLTWH((size.width - minimumSize) / 2,
        (size.height - minimumSize) / 2, minimumSize, minimumSize);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
