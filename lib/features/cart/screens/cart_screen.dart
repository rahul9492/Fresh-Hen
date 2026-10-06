import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../../core/widgets/celebration.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/pop_on_change.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/product_hero.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/staggered_fade_in.dart';
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
import '../../../core/constants/spacing.dart';

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
    Future.microtask(() {
      ref.invalidate(storeSettingsProvider);
      ref.invalidate(productsProvider); // so sold-out items show up
    });
  }

  Future<void> _addAddress() async {
    await showAddressFormSheet(context);
  }

  Future<void> _pickSlot() async {
    final slot = await showDeliverySlotSheet(context, current: ref.read(checkoutProvider).slot);
    if (slot != null) ref.read(checkoutProvider.notifier).schedule(slot);
  }

  void _removeSoldOut() {
    ref.read(cartProvider.notifier).removeAll(ref.read(soldOutLineIdsProvider));
  }

  Future<void> _proceedToPayment() async {
    if (ref.read(soldOutLineIdsProvider).isNotEmpty) {
      context.showError('Some items are sold out. Remove them to continue.');
      return;
    }
    final StoreSettings settings;
    try {
      settings = await ref.read(storeSettingsProvider.future);
    } catch (e) {
      if (mounted) context.showError(e);
      return;
    }
    if (!mounted) return;

    final address = ref.read(selectedAddressProvider);
    if (address != null && !settings.deliversTo(address.pincode)) {
      context.showError(
        "We don't deliver to ${address.pincode} yet. Please choose another address.",
      );
      return showAddressPickerSheet(context);
    }

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

  /// Empties the cart after a confirm, with an Undo that brings everything back.
  Future<void> _clearCart() async {
    final lines = ref.read(cartProvider);
    final count = lines.fold<int>(0, (sum, l) => sum + l.quantity);
    final ok = await showConfirmDialog(
      context,
      icon: Icons.remove_shopping_cart_outlined,
      title: 'Clear your cart?',
      message: 'This removes all $count ${count == 1 ? 'item' : 'items'} from your cart.',
      confirmLabel: 'Clear cart',
      destructive: true,
    );
    if (!ok || !mounted) return;
    // Grab the cart now: once it's empty this screen shows the empty view,
    // and the Undo still needs to reach the cart.
    final cart = ref.read(cartProvider.notifier);
    cart.clear();
    AppSnackbar.info(
      context,
      'Cart cleared',
      actionLabel: 'Undo',
      onAction: () => cart.restoreAll(lines),
    );
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
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          _ClearCartChip(onTap: _clearCart),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          for (final card in [
            if (ref.watch(soldOutLineIdsProvider).isNotEmpty)
              _SoldOutBanner(
                count: ref.watch(soldOutLineIdsProvider).length,
                onRemove: _removeSoldOut,
              ),
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
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: card),
          const _Recommended(),
        ],
      ),
      bottomNavigationBar: _CheckoutBar(
        step: step,
        onAddAddress: _addAddress,
        onPickSlot: _pickSlot,
        onProceed: _proceedToPayment,
        onRemoveSoldOut: _removeSoldOut,
      ),
    );
  }
}

/// "Clear" in the app bar: a soft rose pill with a sweep icon that squishes
/// when pressed, so emptying the cart feels deliberate rather than alarming.
class _ClearCartChip extends StatelessWidget {
  const _ClearCartChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Clear cart',
      excludeSemantics: true,
      child: PressScale(
        scale: 0.92,
        child: Material(
          color: AppColors.accentSoft,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.accent.withValues(alpha: 0.12),
            highlightColor: AppColors.accent.withValues(alpha: 0.06),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 7, 14, 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.primaryDark),
                  SizedBox(width: 6),
                  Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemsCard extends ConsumerWidget {
  const _ItemsCard({required this.lines});

  final List<CartLine> lines;

  /// Swiped away: remove the line, with an Undo that puts it back in the same place.
  void _remove(BuildContext context, WidgetRef ref, CartLine line) {
    final index = lines.indexWhere((l) => l.id == line.id);
    // Grab the cart now: if this was the last item the cart screen is replaced by the
    // empty view, so this widget's `ref` is gone by the time Undo is tapped.
    final cart = ref.read(cartProvider.notifier);
    cart.removeAll({line.id});
    AppSnackbar.info(
      context,
      '${line.name} removed',
      actionLabel: 'Undo',
      onAction: () => cart.restore(line, index),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = lines.fold<int>(0, (sum, l) => sum + l.quantity);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Items in cart ($count)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.hairline),
            Dismissible(
              key: ValueKey(lines[i].id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _remove(context, ref, lines[i]),
              background: const _SwipeToDeleteBackground(),
              child: StaggeredFadeIn(
                index: i,
                child: ColoredBox(color: Colors.white, child: _LineTile(line: lines[i])),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Red strip revealed behind a cart row while it is swiped left.
class _SwipeToDeleteBackground extends StatelessWidget {
  const _SwipeToDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white),
          SizedBox(height: 2),
          Text('Remove', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Warning above the items when some of them can't be bought any more.
class _SoldOutBanner extends StatelessWidget {
  const _SoldOutBanner({required this.count, required this.onRemove});

  final int count;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 item is sold out. Remove it to continue.'
                  : '$count items are sold out. Remove them to continue.',
              style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.3),
            ),
          ),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(count == 1 ? 'Remove' : 'Remove all'),
          ),
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
    final soldOut = ref.watch(soldOutLineIdsProvider.select((ids) => ids.contains(line.id)));
    return Opacity(
      opacity: soldOut ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Tapping a product's photo opens it, the photo growing into the page.
            // Add-ons aren't catalog products, so theirs is just a picture.
            if (line.isAddon)
              ProductImage(asset: line.image, size: 64, radius: 12)
            else
              GestureDetector(
                onTap: () =>
                    context.push(Routes.productFor(line.productId), extra: 'cart-${line.id}'),
                child: ProductHero(
                  tag: 'cart-${line.id}',
                  source: line.image,
                  width: 64,
                  height: 64,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      line.isAddon ? '${line.unitLabel} • Add-on' : line.unitLabel,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (soldOut) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Sold out',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (line.isDiscounted) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Save ${rupees(line.mrpTotal - line.total)}',
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (soldOut)
                  OutlinedButton(
                    onPressed: () => cart.removeAll({line.id}),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      minimumSize: const Size(0, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    ),
                    child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w600)),
                  )
                else
                  QtyStepper(
                    quantity: line.quantity,
                    height: 30,
                    light: true,
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
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      TextSpan(text: rupees(line.total)),
                    ],
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
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
              Text('(Optional)', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            textCapitalization: TextCapitalization.sentences,
            onChanged: ref.read(checkoutProvider.notifier).setInstructions,
            cursorColor: AppColors.primary,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Ring the doorbell, leave at the door...',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.hairline),
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

class _CouponTile extends ConsumerWidget {
  const _CouponTile();

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final coupon = await context.push<Coupon>(Routes.coupons);
    if (coupon == null || !context.mounted) return;
    final saved = ref.read(checkoutBillProvider).discount;
    final celebrated = saved > 0 &&
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Order now', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(
              'Arrives in ${settings.etaLabel}',
              style: const TextStyle(color: AppColors.body, fontSize: 12),
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.body,
                        fontSize: 12,
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
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recommended', style: AppType.display(size: 19)),
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
    required this.onProceed,
    required this.onRemoveSoldOut,
  });

  final CheckoutStep step;
  final VoidCallback onAddAddress;
  final VoidCallback onPickSlot;
  final VoidCallback onProceed;
  final VoidCallback onRemoveSoldOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final settings = ref.watch(currentStoreSettingsProvider);
    final mode = ref.watch(deliveryModeProvider);
    final slot = ref.watch(checkoutProvider.select((s) => s.slot));
    final placing = ref.watch(placeOrderProvider).isLoading;
    final hasSoldOut = ref.watch(soldOutLineIdsProvider).isNotEmpty;

    final (label, action) = switch (step) {
      CheckoutStep.address => (
        settings.scheduleEnabled ? 'Add Address & Slot' : 'Add Delivery Address',
        onAddAddress,
      ),
      CheckoutStep.payment when hasSoldOut => ('Remove sold-out items', onRemoveSoldOut),
      CheckoutStep.payment => ('Proceed to Payment', onProceed),
    };

    return BottomActionBar(
      button: AppButton(label: label, loading: placing, onPressed: action),
      children: [
        // A scheduled order gets its own row (it has its own "Change" link); for
        // "Order now" the delivery time sits inside the address row below.
        if (step == CheckoutStep.payment && mode == DeliveryMode.scheduled && slot != null)
          ActionInfoRow(
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
            actionLabel: 'Change',
            onAction: onPickSlot,
            onTap: onPickSlot,
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
            subtitle: settings.deliversTo(address.pincode)
                ? address.line
                : "We don't deliver to ${address.pincode} yet. Please choose another address.",
            extra: step == CheckoutStep.payment && !(mode == DeliveryMode.scheduled && slot != null)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 15, color: AppColors.success),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Delivery in ${settings.etaLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            actionLabel: 'Change',
            onAction: () => showAddressPickerSheet(context),
            onTap: () => showAddressPickerSheet(context),
          ),
      ],
    );
  }
}
