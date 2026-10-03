import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../../core/widgets/product_image.dart';
import '../../address/providers/address_providers.dart';
import '../../address/widgets/address_form_sheet.dart';
import '../../address/widgets/address_picker_sheet.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/product_grid.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../checkout/widgets/bill_summary.dart';
import '../../checkout/widgets/delivery_slot_sheet.dart';
import '../../checkout/widgets/payment_method_sheet.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_providers.dart';
import '../models/cart_models.dart';
import '../providers/cart_providers.dart';
import '../widgets/empty_cart_view.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Pick up admin changes (schedule switch, fees, QR) every time the cart opens.
    Future.microtask(() => ref.invalidate(storeSettingsProvider));
  }

  Future<void> _addAddress() async {
    final saved = await showAddressFormSheet(context);
    // Address added: go straight to delivery timing.
    if (saved != null) ref.read(checkoutProvider.notifier).confirmTiming();
  }

  Future<void> _pickSlot() async {
    final slot = await showDeliverySlotSheet(context, current: ref.read(checkoutProvider).slot);
    if (slot != null) ref.read(checkoutProvider.notifier).schedule(slot);
  }

  Future<void> _proceedToPayment() async {
    final StoreSettings settings;
    try {
      settings = await ref.read(storeSettingsProvider.future);
    } catch (e) {
      if (mounted) context.showError(e);
      return;
    }
    if (!mounted) return;

    final checkout = ref.read(checkoutProvider);
    final wantsSlot = settings.scheduleEnabled && checkout.mode == DeliveryMode.scheduled;
    final slot = checkout.slot;
    if (wantsSlot && (slot == null || slot.start.isBefore(DateTime.now()))) {
      context.showSnack('Please pick a delivery slot');
      return _pickSlot();
    }

    final method = await showPaymentMethodSheet(
      context,
      amount: ref.read(checkoutBillProvider).total,
      settings: settings,
    );
    if (method == null || !mounted) return;
    if (method == PaymentMethod.upi) {
      context.push(Routes.payment);
      return;
    }
    final order = await ref.read(placeOrderProvider.notifier).submit(method: method);
    if (order != null && mounted) context.go(Routes.orderSuccessFor(order.id));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(placeOrderProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final lines = ref.watch(cartProvider);

    if (lines.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.page,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: EmptyCartView(onBrowse: () => context.go(Routes.home)),
      );
    }

    final step = ref.watch(checkoutStepProvider);
    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(title: const Text('Your cart')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          for (final card in [
            _ItemsCard(lines: lines),
            const _InstructionsCard(),
            const _CouponTile(),
            if (step == CheckoutStep.payment) _DeliveryTimingCard(onPickSlot: _pickSlot),
            AppCard(
              child: BillSummary(
                bill: ref.watch(checkoutBillProvider),
                footer: const _FreeDeliveryHint(),
              ),
            ),
          ])
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: card),
          const _Recommended(),
        ],
      ),
      bottomNavigationBar: _CheckoutBar(
        step: step,
        onAddAddress: _addAddress,
        onPickSlot: _pickSlot,
        onContinue: () => ref.read(checkoutProvider.notifier).confirmTiming(),
        onProceed: _proceedToPayment,
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.lines});

  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final count = lines.fold<int>(0, (sum, l) => sum + l.quantity);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Items in cart ($count)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body),
          ),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.hairline),
            _LineTile(line: lines[i]),
          ],
        ],
      ),
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ProductImage(asset: line.image, size: 64, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 3),
                Text(
                  line.isAddon ? '${line.unitLabel} • Add-on' : line.unitLabel,
                  style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'In Stock',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              QtyStepper(
                quantity: line.quantity,
                height: 30,
                onIncrement: () => cart.increment(line.id),
                onDecrement: () => cart.decrement(line.id),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    if (line.isDiscounted)
                      TextSpan(
                        text: '${rupees(line.mrpTotal)}  ',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    TextSpan(text: rupees(line.total)),
                  ],
                ),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends ConsumerStatefulWidget {
  const _InstructionsCard();

  @override
  ConsumerState<_InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends ConsumerState<_InstructionsCard> {
  late final _controller = TextEditingController(text: ref.read(checkoutProvider).instructions);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 20, color: AppColors.body),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Special Instructions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text('(Optional)', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            textCapitalization: TextCapitalization.sentences,
            onChanged: ref.read(checkoutProvider.notifier).setInstructions,
            cursorColor: AppColors.primary,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Ring the doorbell, leave at the door...',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponTile extends ConsumerWidget {
  const _CouponTile();

  Future<void> _open(BuildContext context) async {
    final coupon = await context.push<Coupon>(Routes.coupons);
    if (coupon != null && context.mounted) {
      context.showSuccess('${coupon.code} applied!');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupon = ref.watch(checkoutProvider.select((s) => s.coupon));
    final issue = ref.watch(couponIssueProvider);
    final discount = ref.watch(checkoutBillProvider.select((b) => b.discount));

    if (coupon == null) {
      return AppCard(
        onTap: () => _open(context),
        child: const Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text('Use Coupons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.body),
          ],
        ),
      );
    }

    final ok = issue == null;
    return AppCard(
      onTap: () => _open(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: ok ? const Color(0xFFF4FBF6) : Colors.white,
      child: Row(
        children: [
          Icon(
            ok ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 22,
            color: ok ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${coupon.code} applied',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ok ? 'You save ${rupees(discount)} with this coupon' : issue,
                  style: TextStyle(
                    color: ok ? AppColors.success : AppColors.primary,
                    fontSize: 12.5,
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

/// "Order now" vs "Schedule for later". Scheduling only appears while the
/// admin has it switched on.
class _DeliveryTimingCard extends ConsumerWidget {
  const _DeliveryTimingCard({required this.onPickSlot});

  final VoidCallback onPickSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentStoreSettingsProvider);
    final mode = ref.watch(deliveryModeProvider);
    final slot = ref.watch(checkoutProvider.select((s) => s.slot));

    if (!settings.scheduleEnabled) {
      return AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Order now', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(
              'Arrives in ${settings.etaLabel}',
              style: const TextStyle(color: AppColors.body, fontSize: 12.5),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _TimingOption(
              icon: Icons.bolt_rounded,
              title: 'Order now',
              subtitle: settings.etaLabel,
              selected: mode == DeliveryMode.now,
              onTap: ref.read(checkoutProvider.notifier).orderNow,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TimingOption(
              icon: Icons.schedule_rounded,
              title: 'Schedule for later',
              subtitle: mode == DeliveryMode.scheduled && slot != null
                  ? formatDayName(slot.start)
                  : 'Pick a slot',
              selected: mode == DeliveryMode.scheduled,
              onTap: onPickSlot,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimingOption extends StatelessWidget {
  const _TimingOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.body,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeDeliveryHint extends ConsumerWidget {
  const _FreeDeliveryHint();

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
            style: const TextStyle(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Recommended extends ConsumerWidget {
  const _Recommended();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider).map((l) => l.productId).toSet();
    final products = ref.watch(productsProvider).value ?? const [];
    final picks = products.where((p) => p.isRecommended && !inCart.contains(p.id)).toList();
    if (picks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recommended', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        ProductRail(products: picks),
      ],
    );
  }
}

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({
    required this.step,
    required this.onAddAddress,
    required this.onPickSlot,
    required this.onContinue,
    required this.onProceed,
  });

  final CheckoutStep step;
  final VoidCallback onAddAddress;
  final VoidCallback onPickSlot;
  final VoidCallback onContinue;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final settings = ref.watch(currentStoreSettingsProvider);
    final mode = ref.watch(deliveryModeProvider);
    final slot = ref.watch(checkoutProvider.select((s) => s.slot));
    final placing = ref.watch(placeOrderProvider).isLoading;

    final (label, action) = switch (step) {
      CheckoutStep.address => (
          settings.scheduleEnabled ? 'Add Address & Slot' : 'Add Delivery Address',
          onAddAddress,
        ),
      CheckoutStep.timing => ('Continue', onContinue),
      CheckoutStep.payment => ('Proceed to Payment', onProceed),
    };

    return BottomActionBar(
      button: AppButton(label: label, loading: placing, onPressed: action),
      children: [
        if (step == CheckoutStep.payment)
          mode == DeliveryMode.scheduled && slot != null
              ? ActionInfoRow(
                  icon: Icons.schedule_rounded,
                  title: Text.rich(
                    TextSpan(
                      text: 'Delivery scheduled for: ',
                      style: const TextStyle(color: AppColors.body),
                      children: [
                        TextSpan(
                          text: slot.shortLabel,
                          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  actionLabel: 'change slot',
                  onAction: onPickSlot,
                )
              : ActionInfoRow(
                  icon: Icons.bolt_rounded,
                  title: Text.rich(
                    TextSpan(
                      text: 'Delivery in ',
                      style: const TextStyle(color: AppColors.body),
                      children: [
                        TextSpan(
                          text: settings.etaLabel,
                          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
        if (address != null)
          ActionInfoRow(
            icon: Icons.location_on_outlined,
            title: Text.rich(
              TextSpan(
                text: 'Delivering to ',
                children: [
                  TextSpan(
                    text: address.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            subtitle: address.line,
            actionLabel: 'change address',
            onAction: () => showAddressPickerSheet(context),
          ),
      ],
    );
  }
}
