import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_providers.dart';
import '../widgets/profile_form.dart';

class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(profileControllerProvider, (_, s) {
      if (s.hasError) context.showSnack(errorMessage(s.error!));
    });
    final loading = ref.watch(profileControllerProvider).isLoading;

    return AuthScaffold(
      showBadge: false,
      title: 'Create Your Profile',
      subtitle: 'Help us serve you better',
      child: ProfileForm(
        submitLabel: 'Complete Setup & Explore',
        loading: loading,
        onSubmit: (name, email) => ref
            .read(profileControllerProvider.notifier)
            .register(phone: phone, name: name, email: email),
      ),
    );
  }
}
