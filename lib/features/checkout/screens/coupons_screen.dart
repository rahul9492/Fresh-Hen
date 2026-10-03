import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/checkout_models.dart';
import '../providers/checkout_providers.dart';

/// Lists the store's coupons and accepts a typed code. Pops with the applied
/// [Coupon] so the cart can confirm the saving.
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  final _code = TextEditingController();
  String? _error;
  var _checking = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String? _issue(Coupon c) => c.issueFor(
        itemTotal: ref.read(cartSummaryProvider).itemTotal,
        isFirstOrder: ref.read(isFirstOrderProvider),
      );

  void _apply(Coupon coupon) {
    final issue = _issue(coupon);
    if (issue != null) {
      setState(() => _error = issue);
      return;
    }
    ref.read(checkoutProvider.notifier).applyCoupon(coupon);
    Navigator.pop(context, coupon);
  }

  Future<void> _applyTyped() async {
    final code = _code.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a coupon code');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final coupon = await ref.read(checkoutRepositoryProvider).findCoupon(code);
      if (!mounted) return;
      setState(() => _checking = false);
      _apply(coupon);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final applied = ref.watch(checkoutProvider.select((s) => s.coupon?.code));
    // Rebuild eligibility when the cart total changes.
    ref.watch(cartSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(title: const Text('Apply Coupon')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (_) => _error == null ? null : setState(() => _error = null),
                    onSubmitted: (_) => _applyTyped(),
                    cursorColor: AppColors.primary,
                    style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    onPressed: _checking ? null : _applyTyped,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _checking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.accent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            'Available Coupons',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AsyncView(
            value: ref.watch(couponsProvider),
            onRetry: () => ref.invalidate(couponsProvider),
            loading: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(height: 110, radius: 16),
                  ),
              ],
            ),
            data: (coupons) => coupons.isEmpty
                ? const EmptyState(
                    icon: Icons.local_offer_outlined,
                    title: 'No coupons right now',
                    message: 'Check back soon for new offers.',
                  )
                : Column(
                    children: [
                      for (final c in coupons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CouponCard(
                            coupon: c,
                            issue: _issue(c),
                            applied: c.code == applied,
                            onApply: () => _apply(c),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.issue,
    required this.applied,
    required this.onApply,
  });

  final Coupon coupon;
  final String? issue;
  final bool applied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final usable = issue == null;
    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: usable ? AppColors.primary : AppColors.border,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppCard.radius)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.code,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: usable ? AppColors.ink : AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coupon.title,
                            style: TextStyle(
                              color: usable ? AppColors.success : AppColors.muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            coupon.description,
                            style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (coupon.minOrder > 0) 'Min. order ${rupees(coupon.minOrder)}',
                              if (coupon.expiresAt != null)
                                'Valid till ${formatShortDate(coupon.expiresAt!)}',
                            ].join('  •  '),
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                          if (!usable) ...[
                            const SizedBox(height: 8),
                            Text(
                              issue!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    applied
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded, size: 15, color: AppColors.success),
                                SizedBox(width: 4),
                                Text(
                                  'Applied',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 34,
                            child: OutlinedButton(
                              onPressed: usable ? onApply : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: usable ? AppColors.primary : AppColors.border,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
