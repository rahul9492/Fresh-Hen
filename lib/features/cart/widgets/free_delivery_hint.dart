import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../providers/cart_providers.dart';

class FreeDeliveryHint extends ConsumerWidget {
  const FreeDeliveryHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentStoreSettingsProvider);
    final remaining = settings.freeDeliveryAbove - ref.watch(cartSummaryProvider).itemTotal;
    if (remaining <= 0 || settings.deliveryFee == 0) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Add ${rupees(remaining)} more for FREE delivery',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
