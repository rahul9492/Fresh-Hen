import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_card.dart';

/// The store couldn't verify the UPI payment: say so plainly and offer help.
class PaymentIssueCard extends StatelessWidget {
  const PaymentIssueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppCard.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We couldn't verify your payment",
                      style: AppType.display(size: 17, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "The payment screenshot didn't match our records. Please contact us and we'll sort it out with you.",
                      style: TextStyle(color: AppColors.ink, fontSize: 13, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push(Routes.help),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            icon: const Icon(Icons.support_agent_rounded, size: 20),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }
}
