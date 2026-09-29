import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/account/screens/account_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/home/screens/categories_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/home/screens/product_list_screen.dart';
import '../../features/home/screens/search_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/orders/screens/order_success_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import 'routes.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authSessionProvider, (_, _) => refresh.value++);
  ref.listen(onboardingSeenProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  String? redirect(String location) {
    final signedIn = ref.read(authSessionProvider) != null;
    final seenOnboarding = ref.read(onboardingSeenProvider);

    if (signedIn) return Routes.publicRoutes.contains(location) ? Routes.home : null;
    if (Routes.publicRoutes.contains(location)) {
      if (location == Routes.root || location == Routes.onboarding) {
        return seenOnboarding ? Routes.login : Routes.onboarding;
      }
      return null;
    }
    return Routes.login;
  }

  return GoRouter(
    initialLocation: Routes.root,
    refreshListenable: refresh,
    redirect: (context, state) => redirect(state.uri.path),
    routes: [
      GoRoute(path: Routes.root, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (_, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (_, state) =>
            ProfileSetupScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.categories, builder: (_, _) => const CategoriesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.orders, builder: (_, _) => const OrdersScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.account, builder: (_, _) => const AccountScreen())],
          ),
        ],
      ),
      GoRoute(path: Routes.cart, builder: (_, _) => const CartScreen()),
      GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: Routes.products,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          return ProductListScreen(
            title: q['title'] ?? 'Products',
            categoryId: q['category'],
            section: q['section'],
          );
        },
      ),
      GoRoute(
        path: Routes.orderSuccess,
        builder: (_, state) => OrderSuccessScreen(orderId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],
  );
}
