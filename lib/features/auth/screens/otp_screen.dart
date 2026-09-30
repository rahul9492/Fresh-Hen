import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/config/env.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';

  String get _spaced => '${widget.phone.substring(0, 5)} ${widget.phone.substring(5)}';

  Future<void> _verify() async {
    final outcome =
        await ref.read(otpControllerProvider.notifier).verify(phone: widget.phone, otp: _otp);
    if (outcome == OtpOutcome.newUser && mounted) {
      context.pushReplacement(Routes.profileSetupFor(widget.phone));
    }
  }

  Future<void> _resend() async {
    ref.read(otpCountdownProvider.notifier).restart();
    await ref.read(loginControllerProvider.notifier).sendOtp(widget.phone);
    if (mounted) context.showSnack('OTP sent to +91 $_spaced');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(otpControllerProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final loading = ref.watch(otpControllerProvider).isLoading;
    final seconds = ref.watch(otpCountdownProvider);

    return AuthScaffold(
      showBack: true,
      title: 'Verify OTP',
      subtitle: 'We have sent a 4 digit code to +91 $_spaced',
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: OtpField(
              onChanged: (v) {
                setState(() => _otp = v);
                if (v.length == AppConstants.otpLength) _verify();
              },
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: seconds > 0
                ? Text.rich(
                    TextSpan(
                      style: const TextStyle(color: AppColors.body, fontSize: 13),
                      children: [
                        const TextSpan(text: "Didn't receive code? "),
                        TextSpan(
                          text: 'Resend in 00:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  )
                : TextButton(onPressed: _resend, child: const Text('Resend OTP')),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Verify & Proceed',
            loading: loading,
            onPressed: _otp.length == AppConstants.otpLength ? _verify : null,
          ),
          if (kDebugMode && Env.useMock) ...[
            const SizedBox(height: 12),
            const Text(
              'Debug: use OTP ${AppConstants.mockOtp}',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
