import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/spacing.dart';
import '../core/push/push_service.dart';
import '../features/cart/widgets/cart_limit_listener.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';

class FreshHenApp extends ConsumerWidget {
  const FreshHenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pushServiceProvider); // starts push notifications
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(goRouterProvider),
      // Dark system buttons on a white strip, identical on every screen. The strip is
      // the system button area plus a small gap; every screen, sheet and dialog is
      // laid out above it, so nothing ever touches the buttons.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final inset = media.viewPadding.bottom + AppSpacing.sm;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Column(
            children: [
              Expanded(
                child: MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(bottom: 0),
                    viewPadding: media.viewPadding.copyWith(bottom: 0),
                    // The strip already covers part of the keyboard's height.
                    viewInsets: media.viewInsets.copyWith(
                      bottom: (media.viewInsets.bottom - inset).clamp(0, double.infinity),
                    ),
                  ),
                  child: CartLimitListener(child: child!),
                ),
              ),
              Container(height: inset, color: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
