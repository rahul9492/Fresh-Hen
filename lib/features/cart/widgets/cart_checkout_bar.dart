import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../address/providers/address_providers.dart';
import '../../address/widgets/address_picker_sheet.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../orders/providers/order_providers.dart';
import '../providers/cart_providers.dart';

class CartCheckoutBar extends ConsumerWidget {
  const CartCheckoutBar({
    super.key,
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
