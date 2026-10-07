import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/constants/spacing.dart';

/// Optional UPI transaction ID (UTR), so the store can match the payment faster.
class PaymentReferenceCard extends StatelessWidget {
  const PaymentReferenceCard({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text.rich(
            TextSpan(
              text: 'UPI Transaction ID ',
              children: [
                TextSpan(
                  text: '(optional)',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '12 digit number from your UPI app',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              helperText: 'Helps us confirm your payment faster',
              helperStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
