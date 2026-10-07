import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/celebration.dart';
import '../../../core/widgets/pop_on_change.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../providers/cart_providers.dart';
import '../../../core/constants/spacing.dart';

/// Small green pill: "3 available". Pops when the count changes (e.g. adding
/// items unlocks another coupon).
class _CouponsAvailable extends StatelessWidget {
  const _CouponsAvailable({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return PopOnChange(
      value: count,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              '$count available',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CouponTile extends ConsumerWidget {
  const CouponTile({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final coupon = await context.push<Coupon>(Routes.coupons);
    if (coupon == null || !context.mounted) return;
    final saved = ref.read(checkoutBillProvider).discount;
    final celebrated =
        saved > 0 &&
        showCelebration(
          context,
          title: '${coupon.code} applied!',
          subtitle: 'You saved ${rupees(saved)} on this order',
        );
    // context.showSuccess('${coupon.code} applied!');
    if (!celebrated) context.showSuccess('${coupon.code} applied!');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupon = ref.watch(checkoutProvider.select((s) => s.coupon));
    final issue = ref.watch(couponIssueProvider);
    final discount = ref.watch(checkoutBillProvider.select((b) => b.discount));

    if (coupon == null) {
      // Coupons that work on this cart right now (same rules as the coupons page).
      final itemTotal = ref.watch(cartSummaryProvider.select((s) => s.itemTotal));
      final firstOrder = ref.watch(isFirstOrderProvider);
      final usable = [
        for (final c in ref.watch(couponsProvider).value ?? const <Coupon>[])
          if (c.issueFor(itemTotal: itemTotal, isFirstOrder: firstOrder) == null) c,
      ];
      final bestSaving = usable.fold(0, (best, c) => math.max(best, c.discountFor(itemTotal)));

      return AppCard(
        onTap: () => _open(context, ref),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Use Coupons',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (bestSaving > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Save up to ${rupees(bestSaving)}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (usable.isNotEmpty) ...[
              _CouponsAvailable(count: usable.length),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.body),
          ],
        ),
      );
    }

    final ok = issue == null;
    return AppCard(
      onTap: () => _open(context, ref),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: ok ? const Color(0xFFF4FBF6) : Colors.white,
      child: Row(
        children: [
          Icon(
            ok ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 22,
            color: ok ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${coupon.code} applied',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ok ? 'You save ${rupees(discount)} with this coupon' : issue,
                  style: TextStyle(
                    color: ok ? AppColors.success : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: ref.read(checkoutProvider.notifier).removeCoupon,
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
