import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/src/game_page/image_controller.dart';
import 'package:mobile/src/models/game_template.dart';
import 'package:mobile/src/replay/replay_service.dart';

const int cheatModeBlinkFrequencyHz = 4;
const int blinkFrequencyHz = 10;
const int blinkTimeout = 2000;
const int msPerSecond = 1000;

class BlinkService {
  img.Image? _leftEndFrame;
  img.Image? _rightEndFrame;
  bool _isCheatModeBlinking = false;
  List<Vec2> _cheatPixels = [];

  void Function() blinkEndCallback = () {};
  final void Function(img.Image, img.Image) _setImages;

  ImageController get _imageController => GetIt.I.get<ImageController>();
  ReplayService get _replayService => GetIt.I.get<ReplayService>();

  BlinkService(this._setImages);

  bool get isCheatModeBlinking => _isCheatModeBlinking;

  void enableCheatModeBlink(List<Vec2> pixelsToBlink) {
    _isCheatModeBlinking = true;
    _cheatPixels = pixelsToBlink;
    _blinkPixels(_cheatPixels);
    // Disable removal of pixels
    _leftEndFrame = _imageController.getRawImage(ImageClicked.left);
    _rightEndFrame = _imageController.getRawImage(ImageClicked.right);
  }

  void disableCheatModeBlink() {
    _isCheatModeBlinking = false;
    blinkEndCallback();
  }

  void blinkPixelsAndRemove(List<Vec2> pixelsToRemove) {
    _blinkPixels(pixelsToRemove);

    if (!_isCheatModeBlinking) {
      _replayService.timer(
          const Duration(milliseconds: blinkTimeout), blinkEndCallback);
      return;
    }

    blinkEndCallback();

    final toRemove = Set.from(pixelsToRemove);
    _cheatPixels =
        _cheatPixels.where((value) => !toRemove.contains(value)).toList();

    enableCheatModeBlink(_cheatPixels);
  }

  void _blinkPixels(List<Vec2> pixelsToBlink) {
    blinkEndCallback();

    final frame1 = _imageController.getRawImage(ImageClicked.left)!;
    final frame2 = _imageController.getRawImage(ImageClicked.right)!;

    var (leftImageFrame1, leftImageFrame2) =
        _computeBlinkFrames(frame1, frame2, pixelsToBlink);
    var (rightImageFrame1, rightImageFrame2) =
        _computeBlinkFrames(frame2, frame1, pixelsToBlink);

    _leftEndFrame = leftImageFrame1;
    _rightEndFrame = rightImageFrame2;

    final freq =
        _isCheatModeBlinking ? cheatModeBlinkFrequencyHz : blinkFrequencyHz;

    final timer = _replayService.periodicTimer(
      Duration(milliseconds: msPerSecond ~/ freq),
      (timer) {
        _setImages(leftImageFrame1, rightImageFrame1);

        (leftImageFrame1, leftImageFrame2) = (leftImageFrame2, leftImageFrame1);
        (rightImageFrame1, rightImageFrame2) =
            (rightImageFrame2, rightImageFrame1);
      },
    );

    bool blinkEnded = false;
    blinkEndCallback = () {
      if (blinkEnded) return;
      blinkEnded = true;
      timer.cancel();
      _setImages(_leftEndFrame!, _rightEndFrame!);
    };
  }

  (img.Image, img.Image) _computeBlinkFrames(
      img.Image original, img.Image modified, List<Vec2> position) {
    img.Image newFrame = original.clone();

    for (var pixel in position) {
      final p = modified.getPixel(pixel.x, pixel.y);
      newFrame.setPixel(pixel.x, pixel.y, p);
    }

    return (original, newFrame);
  }
}
