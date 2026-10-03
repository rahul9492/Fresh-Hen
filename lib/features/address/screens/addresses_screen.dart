import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../models/address.dart';
import '../providers/address_providers.dart';
import '../widgets/address_form_sheet.dart';

const _lavender = Color(0xFFEEF0FF);

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final a in addresses)
            _AddressCard(
              address: a,
              isDefault: a.id == selectedId,
              onMakeDefault: () => ref.read(selectedAddressIdProvider.notifier).select(a.id),
              onEdit: () => showAddressFormSheet(context, existing: a),
              onDelete: () {
                if (!ref.read(addressesProvider.notifier).remove(a.id)) {
                  context.showSnack('You need at least one address');
                }
              },
            ),
          OutlinedButton.icon(
            onPressed: () => showAddressFormSheet(context),
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add_location_alt_rounded, size: 16, color: Colors.white),
            ),
            label: const Text('Add New Delivery Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.primary),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isDefault,
    required this.onMakeDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final bool isDefault;
  final VoidCallback onMakeDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _icon => switch (address.label) {
        AddressLabel.home => Icons.home_rounded,
        AddressLabel.work => Icons.apartment_rounded,
        AddressLabel.other => Icons.place_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDefault ? AppColors.primary : _lavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: isDefault ? Colors.white : AppColors.body, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                address.label.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              _Badge(label: isDefault ? 'Default' : 'Make Default', onTap: isDefault ? null : onMakeDefault),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '+91 ${address.phone}',
                      style: const TextStyle(color: AppColors.body, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.line,
                  style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _lavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Edit', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Default" is a static status chip; "Make Default" is an outlined button so
/// the two are visually distinct and the tappable one reads as an action.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F4E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF1E8E3E)),
            SizedBox(width: 4),
            Text(
              'Default',
              style: TextStyle(
                color: Color(0xFF1E8E3E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radio_button_unchecked_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
