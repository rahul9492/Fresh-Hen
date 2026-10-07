import '../../cart/providers/cart_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_x.dart';
// import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/tab_close_button.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/profile_form.dart';
// import '../../checkout/providers/checkout_providers.dart';
import '../widgets/menu_group.dart';
import '../../../core/constants/spacing.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      title: 'Log out?',
      message: 'You will need to verify your number again to log in.',
      confirmLabel: 'Log out',
      destructive: true,
    );
    if (confirmed) await ref.read(authSessionProvider.notifier).signOut();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.person_remove_outlined,
      title: 'Delete your account?',
      message:
          'Your profile, saved addresses and wishlist will be permanently deleted '
          'and you will be logged out. This cannot be undone.',
      confirmLabel: 'Delete account',
      cancelLabel: 'Keep my account',
      destructive: true,
      preferCancel: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(authSessionProvider.notifier).deleteAccount();
      if (context.mounted) context.showSuccess('Your account has been deleted');
    } catch (e) {
      if (context.mounted) context.showError(e);
    }
  }

  void _edit(BuildContext context, AppUser user) =>
      showAppSheet<void>(context, builder: (_) => _EditProfileSheet(user: user));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    if (user == null) return const SizedBox.shrink();
    // final settings = ref.watch(currentStoreSettingsProvider);
    // final termsUrl = settings.termsUrl.trim();
    // final privacyUrl = settings.privacyUrl.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Same soft down-arrow as the other tabs: closes this tab back to Home.
        leading: const TabCloseButton(),
        leadingWidth: TabCloseButton.width,
        titleSpacing: 12,
        title: const Text('Profile'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          ref.watch(cartSummaryProvider).isEmpty ? 24 : 96, // clear of the View cart bar
        ),
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
                onTap: () => context.push(Routes.wishlist),
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
              // // Pages set in the admin app; without them the built-in text shows.
              // MenuItem(
              //   icon: Icons.description_outlined,
              //   label: termsUrl.isEmpty && privacyUrl.isEmpty ? 'Terms & Privacy' : 'Terms of service',
              //   onTap: () => termsUrl.isEmpty
              //       ? context.push(Routes.terms)
              //       : openLink(context, Uri.parse(termsUrl), error: 'Could not open the page.'),
              // ),
              // if (privacyUrl.isNotEmpty)
              //   MenuItem(
              //     icon: Icons.privacy_tip_outlined,
              //     label: 'Privacy policy',
              //     onTap: () =>
              //         openLink(context, Uri.parse(privacyUrl), error: 'Could not open the page.'),
              //   ),
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
              MenuItem(
                icon: Icons.person_remove_outlined,
                label: 'Delete account',
                color: AppColors.muted,
                showChevron: false,
                onTap: () => _deleteAccount(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '${AppConstants.appName} v1.0.0',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
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
              // A name is required at sign-up, but never trust the server to send one.
              user.name.trim().isEmpty ? '?' : user.name.trim().characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
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
      if (s.hasError) context.showError(s.error!);
    });
    final loading = ref.watch(profileControllerProvider).isLoading;

    return AppSheet(
      title: 'Edit profile',
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ProfileForm(
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
      ),
    );
  }
}
