import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

/// Shows the app's confirm dialog. Returns true only when the user confirms;
/// tapping outside or pressing back counts as cancel.
///
/// * [icon] is shown in a soft circle above the title.
/// * [note] adds a small reassurance line, e.g. "Your cart is saved".
/// * [destructive] paints the confirm action red.
/// * [preferCancel] makes cancel the filled (main) button, for cases where the
///   safe choice is to stay, e.g. leaving a payment half way.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
  String? note,
  IconData noteIcon = Icons.check_circle_rounded,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool preferCancel = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      icon: icon,
      note: note,
      noteIcon: noteIcon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      preferCancel: preferCancel,
    ),
  );
  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.note,
    this.noteIcon = Icons.check_circle_rounded,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.preferCancel = false,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? note;
  final IconData noteIcon;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final bool preferCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final confirmColor = destructive ? AppColors.accent : AppColors.primary;

    void close(bool value) => Navigator.of(context).pop(value);

    // The filled button is the action we want the user to take; the other one
    // is a plain text button underneath.
    final (mainLabel, mainColor, mainValue) = preferCancel
        ? (cancelLabel, AppColors.primary, false)
        : (confirmLabel, confirmColor, true);
    final (otherLabel, otherColor, otherValue) = preferCancel
        ? (confirmLabel, confirmColor, true)
        : (cancelLabel, AppColors.body, false);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: AppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 28, AppSpacing.xxl, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: confirmColor),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.body, height: 1.45),
            ),
            if (note != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(noteIcon, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        note!,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => close(mainValue),
                style: FilledButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                ),
                child: Text(mainLabel),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => close(otherValue),
                style: TextButton.styleFrom(
                  foregroundColor: otherColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: Text(otherLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
