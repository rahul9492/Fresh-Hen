import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../models/address.dart';
import '../providers/address_providers.dart';
import '../widgets/address_form_sheet.dart';
import '../widgets/address_picker_sheet.dart';
import '../../../core/constants/spacing.dart';

const _lavender = Color(0xFFEEF0FF);

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final notifier = ref.read(addressesProvider.notifier);

    /// Changes show at once; if the server refuses, they roll back with a message.
    Future<void> send(Future<void> change) async {
      try {
        await change;
      } catch (e) {
        if (context.mounted) context.showError(e);
      }
    }

    Future<void> delete(Address a) async {
      final ok = await showConfirmDialog(
        context,
        icon: Icons.delete_outline_rounded,
        title: 'Delete address?',
        message: 'Remove "${a.title}" from your saved addresses?',
        confirmLabel: 'Delete',
        destructive: true,
      );
      if (ok) await send(notifier.remove(a.id));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (addresses.isEmpty)
            const SizedBox(
              height: 320,
              child: EmptyState(
                icon: Icons.location_off_outlined,
                title: 'No saved addresses',
                message: 'Add your home, work or any other address for faster checkout.',
              ),
            ),
          for (final (i, a) in addresses.indexed)
            StaggeredFadeIn(
              key: ValueKey(a.id),
              index: i,
              child: _AddressCard(
                address: a,
                isDefault: a.isDefault,
                onMakeDefault: () => send(notifier.makeDefault(a.id)),
                onEdit: () => showAddressFormSheet(context, existing: a),
                onDelete: () => delete(a),
              ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
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
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(addressIcon(address.label), color: isDefault ? Colors.white : AppColors.body, size: 22),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  address.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              _Badge(label: isDefault ? 'Default' : 'Make Default', onTap: isDefault ? null : onMakeDefault),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(AppRadius.md)),
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
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _lavender,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
