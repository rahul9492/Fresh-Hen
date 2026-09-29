import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/context_x.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/widgets/profile_form.dart';
import '../widgets/menu_group.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to verify your number again to log in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed == true) await ref.read(authSessionProvider.notifier).signOut();
  }

  void _edit(BuildContext context, AppUser user) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _EditProfileSheet(user: user),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProfileHeader(user: user, onEdit: () => _edit(context, user)),
          const SizedBox(height: 24),
          MenuGroup(
            items: [
              MenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'My Orders',
                onTap: () => context.go(Routes.orders),
              ),
              MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Manage address',
                onTap: () => context.push(Routes.addresses),
              ),
            ],
          ),
          MenuGroup(
            items: [
              MenuItem(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                onTap: () => context.push(
                  Routes.productsFor(title: 'Wishlist', section: 'wishlist'),
                ),
              ),
            ],
          ),
          MenuGroup(
            items: [
              MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => context.push(Routes.help),
              ),
              MenuItem(
                icon: Icons.description_outlined,
                label: 'Terms & Privacy',
                onTap: () => context.push(Routes.terms),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MenuGroup(
            items: [
              MenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: AppColors.primary,
                showChevron: false,
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '${AppConstants.appName} v1.0.0',
              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.accentSoft,
            child: Text(
              user.name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(user.formattedPhone, style: const TextStyle(color: AppColors.body, fontSize: 14)),
        if (user.email != null)
          Text(user.email!, style: const TextStyle(color: AppColors.body, fontSize: 14)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.body,
            side: const BorderSide(color: AppColors.border),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends ConsumerWidget {
  const _EditProfileSheet({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(profileControllerProvider, (_, s) {
      if (s.hasError) context.showSnack(errorMessage(s.error!));
    });
    final loading = ref.watch(profileControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit profile', style: context.text.titleLarge),
          const SizedBox(height: 16),
          ProfileForm(
            submitLabel: 'Save changes',
            loading: loading,
            initialName: user.name,
            initialEmail: user.email,
            onSubmit: (name, email) async {
              final ok = await ref
                  .read(profileControllerProvider.notifier)
                  .saveChanges(name: name, email: email);
              if (ok && context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
