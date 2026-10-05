import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, this.label = 'FARM FRESH & HANDPICKED'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 7, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsFooter extends StatelessWidget {
  const TermsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5);
    const link = TextStyle(color: Color(0xFF3B4256), fontWeight: FontWeight.w600);
    return const Padding(
      padding: EdgeInsets.fromLTRB(32, 12, 32, 20),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(text: 'Terms of Service', style: link),
            TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: link),
            TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
