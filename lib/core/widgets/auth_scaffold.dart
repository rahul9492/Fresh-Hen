import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'brand_badge.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBadge = true,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBadge;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.authCanvas,
      body: Stack(
        children: [
          const Positioned(top: -60, right: -70, child: _Blob(AppColors.accent, 240)),
          const Positioned(top: 90, left: -90, child: _Blob(AppColors.star, 210)),
          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                      child: IconButton.outlined(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: showBack ? 100 : 170),
                        if (showBadge) ...[const BrandBadge(), const SizedBox(height: 14)],
                        Text(title, style: text.headlineMedium?.copyWith(fontSize: 26)),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: text.bodyLarge?.copyWith(color: AppColors.body, height: 1.4),
                        ),
                        const SizedBox(height: 28),
                        child,
                      ],
                    ),
                  ),
                ),
                const TermsFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob(this.color, this.size);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
