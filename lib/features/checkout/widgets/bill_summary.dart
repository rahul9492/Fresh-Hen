import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dashed_divider.dart';
import '../../orders/models/order_models.dart';

/// Bill breakdown used in the cart, on the payment screen and in order details.
class BillSummary extends StatelessWidget {
  const BillSummary({
    super.key,
    required this.bill,
    this.title = 'Bill Summary',
    this.totalLabel = 'To Pay',
    this.highlightTotal = true,
    this.footer,
  });

  final OrderBill bill;
  final String title;
  final String totalLabel;

  /// Brand-red total (cart, payment); plain ink once the order is paid.
  final bool highlightTotal;

  /// Shown under the total, e.g. a free-delivery hint or savings banner.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _Row('Item Subtotal', rupees(bill.itemTotal)),
        _Row(
          'Delivery Fee',
          bill.deliveryFee == 0 ? 'FREE' : rupees(bill.deliveryFee),
          valueColor: bill.deliveryFee == 0 ? AppColors.success : null,
        ),
        if (bill.discount > 0)
          _Row(
            bill.couponCode == null ? 'Discount' : 'Coupon (${bill.couponCode})',
            '−${rupees(bill.discount)}',
            valueColor: AppColors.success,
          ),
        _Row('Taxes & Packaging', rupees(bill.taxes)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: DashedDivider(),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                totalLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              rupees(bill.total),
              style: TextStyle(
                fontSize: highlightTotal ? 19 : 16,
                fontWeight: FontWeight.w800,
                color: highlightTotal ? AppColors.primary : AppColors.ink,
              ),
            ),
          ],
        ),
        if (bill.savings > 0) ...[
          const SizedBox(height: 12),
          _SavingsBanner(amount: bill.savings),
        ],
        if (footer != null) ...[const SizedBox(height: 10), footer!],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.body, fontSize: 13.5)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsBanner extends StatelessWidget {
  const _SavingsBanner({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.savings_outlined, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'You save ',
                children: [
                  TextSpan(
                    text: rupees(amount),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' on this order'),
                ],
              ),
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
