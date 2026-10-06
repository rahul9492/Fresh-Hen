import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum _SnackKind { info, success, error }

/// Single entry point for user feedback. Prefer the `context.showX` extensions.
abstract final class AppSnackbar {
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      _show(context, message, _SnackKind.info,
          duration: duration, actionLabel: actionLabel, onAction: onAction);

  static void success(BuildContext context, String message) =>
      _show(context, message, _SnackKind.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _SnackKind.error);

  static void _show(
    BuildContext context,
    String message,
    _SnackKind kind, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final (icon, color) = switch (kind) {
      _SnackKind.info => (Icons.info_outline_rounded, Colors.white),
      _SnackKind.success => (Icons.check_circle_rounded, AppColors.success),
      _SnackKind.error => (Icons.error_rounded, const Color(0xFFFF6B6B)),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration ?? const Duration(seconds: 4),
          // Flutter keeps snack bars with an action (e.g. Undo) open until tapped
          // by default; ours should still close on their own after [duration].
          persist: false,
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: const Color(0xFFFFB4A8),
                  onPressed: onAction ?? () {},
                ),
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
