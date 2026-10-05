import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

/// Opens a modal bottom sheet with the app's standard behaviour (keyboard aware,
/// safe area, scroll controlled). [builder] should return an [AppSheet].
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    // Softer dim, and a smooth ease-out slide (no overshoot, which would leave a
    // gap under the sheet) that is a little quicker on the way out.
    barrierColor: Colors.black.withValues(alpha: 0.45),
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      reverseDuration: Duration(milliseconds: 240),
      reverseCurve: Curves.easeInCubic,
    ),
    builder: builder,
  );
}

/// The shared sheet layout: header (title + optional trailing action), a
/// scrollable body and an optional pinned footer. Every sheet uses this so they
/// all look and behave alike.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    this.title,
    this.trailing,
    this.showClose = false,
    required this.child,
    this.footer,
    this.bodyPadding = const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      0,
      AppSpacing.xl,
      AppSpacing.md,
    ),
  });

  final String? title;

  /// Shown at the end of the header, e.g. a "Reset" button.
  final Widget? trailing;

  /// Adds a [SheetCloseButton] at the end of the header.
  final bool showClose;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(title!, style: Theme.of(context).textTheme.titleLarge)),
                  ?trailing,
                  if (showClose) const SheetCloseButton(),
                ],
              ),
            ),
          Flexible(child: SingleChildScrollView(padding: bodyPadding, child: child)),
          if (footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
              ),
              child: footer,
            )
          else
            const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Small round ✕ that closes the sheet, for sheets where tapping outside or
/// swiping down isn't obvious enough.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Close',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close_rounded, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: AppColors.ink,
        fixedSize: const Size(36, 36),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
