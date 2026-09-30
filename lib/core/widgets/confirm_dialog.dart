import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Returns true only when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive ? TextButton.styleFrom(foregroundColor: AppColors.accent) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
