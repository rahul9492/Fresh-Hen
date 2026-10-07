import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../address/providers/address_providers.dart';
import '../../address/widgets/address_form_sheet.dart';
import '../../address/widgets/address_picker_sheet.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../checkout/widgets/bill_summary.dart';
import '../../checkout/widgets/delivery_slot_sheet.dart';
import '../../checkout/widgets/payment_method_sheet.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_providers.dart';
import '../providers/cart_providers.dart';
import '../widgets/empty_cart_view.dart';
import '../widgets/clear_cart_chip.dart';
import '../widgets/cart_items_card.dart';
import '../widgets/instructions_card.dart';
import '../widgets/coupon_tile.dart';
import '../widgets/delivery_timing_card.dart';
import '../widgets/free_delivery_hint.dart';
import '../widgets/cart_recommended.dart';
import '../widgets/cart_checkout_bar.dart';

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
          ClearCartChip(onTap: _clearCart),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          for (final card in [
            if (ref.watch(soldOutLineIdsProvider).isNotEmpty)
              SoldOutBanner(
                count: ref.watch(soldOutLineIdsProvider).length,
                onRemove: _removeSoldOut,
              ),
            CartItemsCard(lines: lines),
            const InstructionsCard(),
            const CouponTile(),
            if (step == CheckoutStep.payment) DeliveryTimingCard(onPickSlot: _pickSlot),
            AppCard(
              child: BillSummary(
                bill: ref.watch(checkoutBillProvider),
                footer: const FreeDeliveryHint(),
              ),
            ),
          ])
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: card),
          const CartRecommended(),
        ],
      ),
      bottomNavigationBar: CartCheckoutBar(
        step: step,
        onAddAddress: _addAddress,
        onPickSlot: _pickSlot,
        onProceed: _proceedToPayment,
        onRemoveSoldOut: _removeSoldOut,
      ),
    );
  }
}
