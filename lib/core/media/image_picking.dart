import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/context_x.dart';

export 'package:image_picker/image_picker.dart' show ImageSource;

/// An image the user picked or took, ready to upload.
class PickedImage {
  const PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;

  int get sizeInBytes => bytes.lengthInBytes;
}

/// Opens the gallery or the camera and returns the image, or null when the user
/// cancels or the image can't be used. Problems (no permission, too large) are
/// shown to the user here, so callers only handle the happy path.
///
/// Large photos are scaled down to [maxWidth] and re-compressed, so camera
/// shots of another phone's screen stay small enough to upload quickly.
Future<PickedImage?> pickImage(
  BuildContext context, {
  ImageSource source = ImageSource.gallery,
  int maxBytes = 10 * 1024 * 1024,
  double maxWidth = 2000,
  int imageQuality = 85,
}) async {
  final camera = source == ImageSource.camera;
  try {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    if (file == null) return null; // user backed out
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > maxBytes) {
      if (context.mounted) {
        context.showError(
          'That image is too large. Please use one under ${maxBytes ~/ (1024 * 1024)} MB.',
        );
      }
      return null;
    }
    return PickedImage(bytes: bytes, name: file.name);
  } on PlatformException catch (e) {
    if (context.mounted) {
      final denied = e.code.contains('denied') || e.code.contains('access');
      context.showError(switch ((denied, camera)) {
        (true, true) => 'Allow camera access in Settings to take a photo.',
        (true, false) => 'Allow photo access in Settings to choose an image.',
        (false, true) => 'Could not open the camera. Please try again.',
        (false, false) => 'Could not open your gallery. Please try again.',
      });
    }
    return null;
  }
}
