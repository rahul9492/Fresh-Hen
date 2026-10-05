import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../models/order_models.dart';
import '../../../core/constants/spacing.dart';

/// Asks why the customer wants to cancel [order]. Returns the reason, or null
/// if they keep the order.
Future<String?> showCancelOrderSheet(BuildContext context, {required Order order}) =>
    showAppSheet<String>(context, builder: (_) => _CancelOrderSheet(order: order));

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet({required this.order});

  final Order order;

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  static const _reasons = [
    'Ordered by mistake',
    'Want to change items or quantity',
    'Delivery time is too late',
    'Wrong delivery address',
    'Other',
  ];

  String? _reason;

  @override
  Widget build(BuildContext context) {
    final paidByUpi = widget.order.paymentMethod == PaymentMethod.upi;
    return AppSheet(
      title: 'Cancel order?',
      showClose: true,
      footer: AppButton(
        label: 'Cancel order',
        onPressed: _reason == null ? null : () => Navigator.pop(context, _reason),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tell us why, so we can do better next time.',
            style: TextStyle(color: AppColors.body, fontSize: 14),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: (r) => setState(() => _reason = r),
            child: Column(
              children: [
                for (final r in _reasons)
                  RadioListTile<String>(
                    value: r,
                    title: Text(r, style: const TextStyle(fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.primary,
                  ),
              ],
            ),
          ),
          if (paidByUpi) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.currency_rupee_rounded, size: 18, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your UPI payment will be refunded by the store to the same account.',
                      style: TextStyle(color: AppColors.success, fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
