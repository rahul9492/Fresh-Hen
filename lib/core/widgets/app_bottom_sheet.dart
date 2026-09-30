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
