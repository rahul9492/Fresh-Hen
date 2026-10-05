import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../media/image_picking.dart';
import '../constants/spacing.dart';

/// Split upload button: the wide part picks from the gallery, the square part
/// beside it opens the camera. Handles picking and its errors; the screen only
/// decides what to do with the image in [onImage].
///
/// ```dart
/// ImageUploadButton(
///   label: 'Upload Screenshot',
///   onImage: (image) => upload(image),
/// )
/// ```
class ImageUploadButton extends StatefulWidget {
  const ImageUploadButton({
    super.key,
    required this.label,
    required this.onImage,
    this.icon = Icons.photo_library_outlined,
    this.showCamera = true,
    this.cameraTooltip = 'Take a photo',
    this.loading = false,
    this.beforePick,
    this.maxBytes = 10 * 1024 * 1024,
  });

  final String label;
  final IconData icon;

  /// Called with the picked image. May be async; the button shows a spinner
  /// until [loading] turns false.
  final ValueChanged<PickedImage> onImage;

  /// Hide the camera part where a photo makes no sense.
  final bool showCamera;
  final String cameraTooltip;

  /// Busy state from the caller, e.g. while the image uploads.
  final bool loading;

  /// Runs before the picker opens; return false to stop (e.g. a form is invalid).
  final bool Function()? beforePick;
  final int maxBytes;

  static const height = 52.0;

  @override
  State<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends State<ImageUploadButton> {
  var _picking = false;

  bool get _busy => _picking || widget.loading;

  Future<void> _pick(ImageSource source) async {
    if (_busy || !(widget.beforePick?.call() ?? true)) return;
    setState(() => _picking = true);
    final image = await pickImage(context, source: source, maxBytes: widget.maxBytes);
    if (!mounted) return;
    setState(() => _picking = false);
    if (image != null) widget.onImage(image);
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: ImageUploadButton.height,
            child: FilledButton(
              onPressed: widget.loading ? null : () => _pick(ImageSource.gallery),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: shape,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              // The spinner is for the upload only; while the camera or gallery is
              // open the button keeps its label (taps are ignored by _pick).
              child: widget.loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, size: 20),
                        const SizedBox(width: 8),
                        // Long labels shrink a little instead of being cut off.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(widget.label, maxLines: 1),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (widget.showCamera) ...[
          const SizedBox(width: 12),
          Tooltip(
            message: widget.cameraTooltip,
            child: SizedBox.square(
              dimension: ImageUploadButton.height,
              child: OutlinedButton(
                onPressed: widget.loading ? null : () => _pick(ImageSource.camera),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: _busy ? AppColors.border : AppColors.primary,
                    width: 1.4,
                  ),
                  shape: shape,
                ),
                child: Semantics(
                  label: widget.cameraTooltip,
                  child: const Icon(Icons.photo_camera_outlined, size: 24),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
