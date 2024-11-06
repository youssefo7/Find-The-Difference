import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/auth/auth_controller.dart'; // Import if you need to call the API for updating the avatar
import 'package:mobile/src/auth/auth_service.dart';
import 'package:mobile/src/avatar/avatar_notifier.dart';
import 'package:mobile/src/camera/camera_preview_dialog.dart';
import 'package:mobile/src/services/bucket_service.dart';

class AvatarInputView extends StatefulWidget {
  const AvatarInputView({
    super.key,
    this.onValueChanged,
    this.isEditingMode = false,
  });

  final void Function(String value)? onValueChanged;
  final bool isEditingMode;

  @override
  State<AvatarInputView> createState() => _AvatarInputViewState();
}

class _AvatarInputViewState extends State<AvatarInputView> {
  ImageProvider _avatarImage;
  String _selectedAvatarUrl;
  final _avatarImageSize = 128.0;
  final _avatarChipSize = 60.0;

  AvatarNotifier get _avatarNotifier => GetIt.I.get<AvatarNotifier>();

  _AvatarInputViewState()
      : _selectedAvatarUrl = GetIt.I.get<BucketService>().defaultAvatarUrls[0],
        _avatarImage =
            NetworkImage(GetIt.I.get<BucketService>().defaultAvatarUrls[0]);

  void _updateAvatar(String url) {
    setState(() {
      _selectedAvatarUrl = url;
      _avatarImage = NetworkImage(url);
    });
    _avatarNotifier.updateAvatarUrl(url);
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(url);
    }
  }

  Padding get _avatar => Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: _avatarImageSize / 2,
          backgroundImage: _avatarImage,
        ),
      );

  GestureDetector _getDefaultAvatarChip(String url) {
    return GestureDetector(
      onTap: () => _updateAvatar(url),
      child: CircleAvatar(
        radius: _avatarChipSize / 2,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  Column get _avatarChipsGrid {
    final numberOfAvatars =
        GetIt.I.get<BucketService>().defaultAvatarUrls.length;
    final numberOfRows = sqrt(numberOfAvatars).ceil();
    final numberOfColumns = numberOfAvatars ~/ numberOfRows;
    int numberOfElementsInLastRow = numberOfAvatars % numberOfColumns;
    if (numberOfElementsInLastRow == 0) {
      numberOfElementsInLastRow = numberOfColumns;
    }

    return Column(
      children: List.generate(
        numberOfRows,
        (rowIndex) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            rowIndex == numberOfRows - 1
                ? numberOfElementsInLastRow
                : numberOfColumns,
            (columnIndex) {
              final index = rowIndex * numberOfColumns + columnIndex;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getDefaultAvatarChip(
                    GetIt.I.get<BucketService>().defaultAvatarUrls[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  ElevatedButton get _takePictureButton => ElevatedButton.icon(
        onPressed: () {
          if (!Platform.isAndroid) return;
          showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return CameraPreviewDialog(previewSize: _avatarImageSize);
            },
          ).then((String? base64Image) {
            if (base64Image != null) {
              setState(() {
                _avatarImage = MemoryImage(base64Decode(base64Image));
                _selectedAvatarUrl = 'data:image/png;base64,$base64Image';
                _avatarNotifier.updateAvatarUrl(_selectedAvatarUrl);
                if (widget.onValueChanged != null) {
                  widget.onValueChanged!(_selectedAvatarUrl);
                }
              });
            }
          });
        },
        icon: const Icon(Icons.camera_alt),
        label: Text(AppLocalizations.of(context)!.takePicture),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          _avatar,
          _avatarChipsGrid,
        ]),
        const SizedBox(height: 16),
        _takePictureButton,
        if (widget.isEditingMode)
          ElevatedButton(
            onPressed: () async {
              String trimmedAvatarUrl =
                  GetIt.I.get<AuthService>().trimURL(_selectedAvatarUrl);
              final success = await GetIt.I
                  .get<AuthController>()
                  .updateAvatar(context, trimmedAvatarUrl);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
      ],
    );
  }
}
