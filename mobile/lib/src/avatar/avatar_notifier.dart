import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/services/bucket_service.dart';

class AvatarNotifier extends ChangeNotifier {
  String _avatarUrl = GetIt.I.get<BucketService>().defaultAvatarUrls[0];

  String get avatarUrl => _avatarUrl;

  void updateAvatarUrl(String newUrl) {
    _avatarUrl = newUrl;
    notifyListeners();
  }

  void resetAvatarUrl() {
    _avatarUrl = GetIt.I.get<BucketService>().defaultAvatarUrls[0];
    notifyListeners();
  }
}
