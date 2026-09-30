import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Shows an asset path or a remote URL (http/https) with a loading placeholder
/// and an error fallback. Lets the UI stay unchanged when the backend serves
/// real image URLs instead of bundled assets.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isRemote => source.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (!_isRemote) {
      return Image.asset(source, width: width, height: height, fit: fit, errorBuilder: _error);
    }
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _error,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : SizedBox(
              width: width,
              height: height,
              child: const ColoredBox(color: Color(0xFFF1F1F3)),
            ),
    );
  }

  Widget _error(BuildContext context, Object error, StackTrace? stack) => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: AppColors.accentSoft,
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.muted),
        ),
      );
}
