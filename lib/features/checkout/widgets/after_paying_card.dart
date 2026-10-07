import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/constants/spacing.dart';

/// What to do after paying.
class AfterPayingCard extends StatelessWidget {
  const AfterPayingCard({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('How to pay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _Step(number: 1, text: 'Scan the QR with any UPI app and pay exactly ${rupees(amount)}.'),
          const _Step(number: 2, text: 'Take a screenshot of the payment success screen.'),
          const _Step(
            number: 3,
            text:
                'Upload it using the button below. We confirm your order once the payment '
                'is verified.',
          ),
          const _CameraHint(),
        ],
      ),
    );
  }
}

/// Points people who paid from another phone to the camera button.
class _CameraHint extends StatelessWidget {
  const _CameraHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Row(
        children: [
          Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Paid from another phone? Tap the camera button to take a photo of its payment screen.',
              style: TextStyle(color: AppColors.body, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.accentSoft,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
