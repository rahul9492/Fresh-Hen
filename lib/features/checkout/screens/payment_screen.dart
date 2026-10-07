import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/media/image_picking.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/image_upload_button.dart';
import '../../cart/providers/cart_providers.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_providers.dart';
import '../providers/checkout_providers.dart';
import '../widgets/bill_summary.dart';
import '../widgets/upi_qr_card.dart';
import '../widgets/after_paying_card.dart';
import '../widgets/payment_reference_card.dart';
import '../widgets/payment_unavailable.dart';

/// Pay by scanning the store's UPI QR (uploaded from the admin app), then
/// upload the payment screenshot: the order is placed with it straight away
/// and confirmed once the store verifies the payment. The QR is static, so
/// there is no payment window or countdown.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _reference = TextEditingController();

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  /// The UPI reference is optional, but if typed it must be 12 digits.
  bool _referenceValid() {
    final reference = _reference.text.trim();
    if (reference.isEmpty || RegExp(r'^\d{12}$').hasMatch(reference)) return true;
    context.showError('The UPI transaction ID has 12 digits. Check it or leave it empty.');
    return false;
  }

  /// Places the order with the screenshot or photo the customer just picked.
  Future<void> _placeWith(PickedImage proof) async {
    final order = await ref
        .read(placeOrderProvider.notifier)
        .submit(method: PaymentMethod.upi, proof: proof, paymentReference: _reference.text.trim());
    if (order != null && mounted) context.go(Routes.orderSuccessFor(order.id));
  }

  /// Leaving after paying would lose the order, so confirm first.
  Future<void> _confirmLeave() async {
    final leave = await showConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: 'Leave payment?',
      message:
          'If you have already paid, stay and upload the payment screenshot so we can '
          'confirm your order.',
      note: 'Your cart is saved',
      noteIcon: Icons.shopping_cart_rounded,
      confirmLabel: 'Leave anyway',
      cancelLabel: 'Stay & upload screenshot',
      destructive: true,
      preferCancel: true,
    );
    if (leave && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(placeOrderProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final placing = ref.watch(placeOrderProvider).isLoading;
    final bill = ref.watch(checkoutBillProvider);
    final settings = ref.watch(storeSettingsProvider);
    final cartEmpty = ref.watch(cartSummaryProvider).isEmpty;

    return PopScope(
      // Someone may already have paid, so leaving always asks first.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !placing) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.page,
        appBar: AppBar(title: const Text('Payment')),
        body: AsyncView(
          value: settings,
          onRetry: () => ref.invalidate(storeSettingsProvider),
          data: (settings) {
            if (!settings.upiEnabled) {
              return const PaymentUnavailable();
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                UpiQrCard(settings: settings, amount: bill.total),
                const SizedBox(height: 16),
                AfterPayingCard(amount: bill.total),
                const SizedBox(height: 16),
                PaymentReferenceCard(controller: _reference),
                const SizedBox(height: 16),
                AppCard(child: BillSummary(bill: bill)),
              ],
            );
          },
        ),
        bottomNavigationBar: cartEmpty
            ? null
            : BottomActionBar(
                button: ImageUploadButton(
                  label: 'Upload Screenshot',
                  cameraTooltip: 'Take a photo of the payment screen',
                  loading: placing,
                  beforePick: _referenceValid,
                  onImage: _placeWith,
                ),
              ),
      ),
    );
  }
}
