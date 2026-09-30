import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum _SnackKind { info, success, error }

/// Single entry point for user feedback. Prefer the `context.showX` extensions.
abstract final class AppSnackbar {
  static void info(BuildContext context, String message) =>
      _show(context, message, _SnackKind.info);

  static void success(BuildContext context, String message) =>
      _show(context, message, _SnackKind.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _SnackKind.error);

  static void _show(BuildContext context, String message, _SnackKind kind) {
    final (icon, color) = switch (kind) {
      _SnackKind.info => (Icons.info_outline_rounded, Colors.white),
      _SnackKind.success => (Icons.check_circle_rounded, AppColors.success),
      _SnackKind.error => (Icons.error_rounded, const Color(0xFFFF6B6B)),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
