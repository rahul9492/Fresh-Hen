import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/open_saved_file.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dashed_divider.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';
import '../services/invoice_pdf.dart';
import '../../../core/constants/spacing.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  var _busy = false;

  Future<void> _download(Order order) async {
    setState(() => _busy = true);
    try {
      final seller = await ref.read(storeSettingsProvider.future);
      // await shareInvoicePdf(order, seller);
      final uri = await downloadInvoicePdf(order, seller);
      if (uri != null && mounted) {
        // context.showSnack('Invoice saved to Downloads');
        AppSnackbar.info(
          context,
          'Invoice saved to Downloads',
          actionLabel: 'Open',
          onAction: () async {
            if (!await openSavedPdf(uri) && mounted) {
              context.showError('No app found to open PDFs.');
            }
          },
        );
      }
    } catch (e) {
      if (mounted) context.showError('Could not create the invoice. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    final order = ref.read(orderProvider(widget.orderId)).value;
    if (order == null || !order.hasInvoice) return;
    setState(() => _busy = true);
    try {
      final seller = await ref.read(storeSettingsProvider.future);
      await shareInvoicePdf(order, seller);
    } catch (e) {
      if (mounted) context.showError('Could not create the invoice. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(
        title: const Text('Download Invoice'),
        actions: [
          // Sharing stays available for people who want to send the PDF on.
          IconButton(
            tooltip: 'Share invoice',
            icon: const Icon(Icons.share_outlined),
            onPressed: _busy ? null : _share,
          ),
        ],
      ),
      body: AsyncView(
        value: ref.watch(orderProvider(widget.orderId)),
        onRetry: () => ref.invalidate(ordersProvider),
        data: (order) {
          if (order == null || !order.hasInvoice) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Invoice not available',
              message: 'The tax invoice is ready once your order is delivered.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _InvoiceCard(order: order),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _download(order),
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Download Invoice'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Saves the PDF to your Downloads folder.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final bill = order.bill;
    final paid = order.paymentStatus == PaymentStatus.paid;

    Widget row(String label, String value, {Color? color, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? AppColors.ink : AppColors.body,
                fontSize: bold ? 15.5 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15.5 : 13,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.accentSoft,
              child: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Order Invoice',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${order.id} • ${formatFullDate(order.placedAt)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.body, fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.hairline),
          ),
          for (var i = 0; i < order.lines.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DashedDivider(color: AppColors.hairline),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.lines[i].name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.lines[i].unitLabel} x ${order.lines[i].quantity}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  rupees(order.lines[i].total),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.hairline),
          ),
          row('Subtotal', rupees(bill.itemTotal)),
          row(
            'Delivery Fee',
            bill.deliveryFee == 0 ? 'FREE' : rupees(bill.deliveryFee),
            color: bill.deliveryFee == 0 ? AppColors.success : null,
          ),
          if (bill.discount > 0)
            row(
              bill.couponCode == null ? 'Discount' : 'Coupon (${bill.couponCode})',
              '−${rupees(bill.discount)}',
              color: AppColors.success,
            ),
          row('Taxes & Packaging', rupees(bill.taxes)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.hairline),
          ),
          row(paid ? 'Total Paid' : 'Total Amount', rupees(bill.total), bold: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.hairline),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment Method',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              Text(
                order.paymentMethod == PaymentMethod.upi ? 'UPI • Scan & Pay' : 'Cash on Delivery',
                style: const TextStyle(color: AppColors.body, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
