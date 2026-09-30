import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phone = _phone.text;
    final sent = await ref.read(loginControllerProvider.notifier).sendOtp(phone);
    if (sent && mounted) context.push(Routes.otpFor(phone));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginControllerProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final loading = ref.watch(loginControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Welcome Back',
      subtitle:
          'Enter your mobile number to get freshly cut chicken & prime artisanal meats delivered to your door.',
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Text('+91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phone,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    cursorColor: AppColors.primary,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                    onSubmitted: (_) => Validators.isPhone(_phone.text) ? _continue() : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _phone,
            builder: (_, value, _) => AppButton(
              label: 'Continue',
              loading: loading,
              onPressed: Validators.isPhone(value.text) ? _continue : null,
            ),
          ),
        ],
      ),
    );
  }
}
