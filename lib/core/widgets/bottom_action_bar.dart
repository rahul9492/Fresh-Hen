import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// White bar pinned under a screen's content: optional info rows on top of the
/// main button. Use as `Scaffold.bottomNavigationBar`.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.button, this.children = const []});

  final Widget button;

  /// Rows shown above the button, each separated by a hairline.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final child in children) ...[
              child,
              const Divider(height: 1, thickness: 1, color: AppColors.hairline),
            ],
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: button),
          ],
        ),
      ),
    );
  }
}

/// Icon + text row with an optional action link, e.g. "Delivering to Home ... change address".
class ActionInfoRow extends StatelessWidget {
  const ActionInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines = 2,
    this.extra,
    this.actionLabel,
    this.onAction,
    this.onTap,
  });

  final IconData icon;

  /// Usually a [Text.rich] so part of it can be bold.
  final Widget title;
  final String? subtitle;
  final int subtitleMaxLines;

  /// Optional line under the subtitle, e.g. the delivery time.
  final Widget? extra;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Tapping anywhere on the row (not just the link) does this.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 18, color: AppColors.body),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                    ),
                  ],
                  if (extra != null) ...[const SizedBox(height: 4), extra!],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              LinkAction(label: actionLabel!, onTap: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small green "✎ change address" style link.
class LinkAction extends StatelessWidget {
  const LinkAction({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.edit_note_rounded,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  static const color = Color(0xFF178A4C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
