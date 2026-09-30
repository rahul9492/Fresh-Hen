import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.success,
                  child: Icon(Icons.check_rounded, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              Text('Order placed!', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Order #$orderId is confirmed. Your fresh cuts will reach you shortly.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: AppColors.body),
              ),
              const Spacer(),
              AppButton(label: 'Track in Orders', onPressed: () {
                  context.go(Routes.home);
                  context.push(Routes.orders);
                }),
              TextButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Continue shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
