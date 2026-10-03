import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../orders/models/order_models.dart';
import '../models/checkout_models.dart';

/// Asks how the customer wants to pay [amount]. Returns the method, or null.
Future<PaymentMethod?> showPaymentMethodSheet(
  BuildContext context, {
  required int amount,
  required StoreSettings settings,
}) =>
    showAppSheet<PaymentMethod>(
      context,
      builder: (_) => _PaymentMethodSheet(amount: amount, settings: settings),
    );

class _PaymentMethodSheet extends StatefulWidget {
  const _PaymentMethodSheet({required this.amount, required this.settings});

  final int amount;
  final StoreSettings settings;

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  late PaymentMethod? _method = widget.settings.upiEnabled
      ? PaymentMethod.upi
      : (widget.settings.cashOnDeliveryEnabled ? PaymentMethod.cash : null);

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final amount = rupees(widget.amount);
    return AppSheet(
      title: 'Choose payment method',
      footer: AppButton(
        label: switch (_method) {
          PaymentMethod.cash => 'Place Order • $amount',
          PaymentMethod.upi => 'Continue to Pay $amount',
          null => 'Payments unavailable',
        },
        onPressed: _method == null ? null : () => Navigator.pop(context, _method),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: 'Amount to pay  ',
              children: [
                TextSpan(
                  text: amount,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            style: const TextStyle(color: AppColors.body, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _MethodOption(
            icon: Icons.qr_code_2_rounded,
            title: 'Pay Online via UPI',
            subtitle: s.upiEnabled
                ? 'Scan our QR with any UPI app, then upload the payment screenshot.'
                : 'Currently unavailable',
            badges: s.upiEnabled ? const ['GPay', 'PhonePe', 'Paytm', 'BHIM'] : const [],
            selected: _method == PaymentMethod.upi,
            enabled: s.upiEnabled,
            onTap: () => setState(() => _method = PaymentMethod.upi),
          ),
          const SizedBox(height: 12),
          _MethodOption(
            icon: Icons.payments_outlined,
            title: 'Cash on Delivery',
            subtitle: s.cashOnDeliveryEnabled
                ? 'Pay in cash when your order arrives.'
                : 'Currently unavailable',
            selected: _method == PaymentMethod.cash,
            enabled: s.cashOnDeliveryEnabled,
            onTap: () => setState(() => _method = PaymentMethod.cash),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.badges = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppColors.ink : AppColors.muted;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: selected ? AppColors.accentSoft.withValues(alpha: 0.55) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: selected ? Colors.white : AppColors.body),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.body, fontSize: 12.5, height: 1.35),
                      ),
                      if (badges.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final b in badges)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.hairline),
                                ),
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.body,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
