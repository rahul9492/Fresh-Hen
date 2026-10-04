import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Shows an asset path or a remote URL (http/https) with a loading placeholder
/// and an error fallback. Lets the UI stay unchanged when the backend serves
/// real image URLs instead of bundled assets.
///
/// Remote images are cached on the device, so a product photo downloads once
/// instead of on every screen, and are decoded at the size they are shown.
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
    final w = width;
    return CachedNetworkImage(
      imageUrl: source,
      width: w,
      height: height,
      fit: fit,
      // Decode no bigger than shown, so long product lists stay light on memory.
      memCacheWidth: w != null && w.isFinite ? (w * MediaQuery.devicePixelRatioOf(context)).round() : null,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, _) => SizedBox(width: w, height: height, child: const ColoredBox(color: Color(0xFFF1F1F3))),
      errorWidget: (context, _, error) => _error(context, error, null),
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
