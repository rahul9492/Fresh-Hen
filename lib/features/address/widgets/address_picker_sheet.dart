import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/address.dart';
import '../providers/address_providers.dart';
import 'address_form_sheet.dart';

IconData addressIcon(AddressLabel label) => switch (label) {
      AddressLabel.home => Icons.home_rounded,
      AddressLabel.work => Icons.work_rounded,
      AddressLabel.other => Icons.place_rounded,
    };

/// Lets the customer pick which saved address the order goes to, or add one.
Future<void> showAddressPickerSheet(BuildContext context) =>
    showAppSheet<void>(context, builder: (_) => const _AddressPickerSheet());

class _AddressPickerSheet extends ConsumerWidget {
  const _AddressPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);
    final settings = ref.watch(currentStoreSettingsProvider);

    Future<void> addNew() async {
      final saved = await showAddressFormSheet(context);
      if (saved != null && context.mounted) Navigator.pop(context);
    }

    return AppSheet(
      title: 'Select delivery address',
      child: Column(
        children: [
          for (final a in addresses) ...[
            _AddressOption(
              address: a,
              selected: a.id == selectedId,
              deliverable: settings.deliversTo(a.pincode),
              onTap: () {
                ref.read(selectedAddressIdProvider.notifier).select(a.id);
                Navigator.pop(context);
              },
              onEdit: () => showAddressFormSheet(context, existing: a),
            ),
            const SizedBox(height: 10),
          ],
          InkWell(
            onTap: addNew,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add new address',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.deliverable,
    required this.onTap,
    required this.onEdit,
  });

  final Address address;
  final bool selected;

  /// False for an address outside the delivery area: it can't be picked.
  final bool deliverable;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentSoft.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: deliverable ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
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
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primary : AppColors.muted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(addressIcon(address.label), size: 16, color: AppColors.body),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            address.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.line,
                      style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.name} • +91 ${address.phone}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    if (!deliverable) ...[
                      const SizedBox(height: 6),
                      Text(
                        "We don't deliver to ${address.pincode} yet",
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit address',
                icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
