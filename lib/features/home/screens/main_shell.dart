import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/lottie_nav_icon.dart';
import '../../cart/widgets/view_cart_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: LottieNavIcon('assets/lottie/home.json', fallback: Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: LottieNavIcon(
        'assets/lottie/categories.json',
        fallback: Icons.grid_view_rounded,
      ),
      label: 'Categories',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: LottieNavIcon(
        'assets/lottie/orders.json',
        fallback: Icons.receipt_long_rounded,
      ),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: LottieNavIcon('assets/lottie/account.json', fallback: Icons.person_rounded),
      label: 'Account',
    ),
  ];

  /// Tabs are the bottom of the stack, so Android back would close the app.
  /// Instead: other tabs go back to Home, and Home asks before exiting.
  Future<void> _onBack(BuildContext context) async {
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return;
    }
    final exit = await showConfirmDialog(
      context,
      icon: Icons.exit_to_app_rounded,
      title: 'Exit app?',
      message: 'Are you sure you want to close Fresh Hen?',
      confirmLabel: 'Exit',
      cancelLabel: 'Stay',
      destructive: true,
      preferCancel: true,
    );
    if (exit) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            shell,
            const Align(alignment: Alignment.bottomCenter, child: ViewCartBar()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          destinations: _destinations,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
    );
  }
}
