import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

class PaymentUnavailable extends StatelessWidget {
  const PaymentUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              'UPI payments are unavailable right now',
              textAlign: TextAlign.center,
              style: AppType.display(size: 17),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please go back and choose Cash on Delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.body),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => context.pop(), child: const Text('Back to cart')),
          ],
        ),
      ),
    );
  }
}
