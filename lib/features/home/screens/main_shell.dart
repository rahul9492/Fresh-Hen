import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/providers/cart_providers.dart';
import '../../cart/widgets/view_cart_bar.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _cartIndex = 2;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Categories',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartSummaryProvider).itemCount;
    final destinations = [
      ..._destinations.take(_cartIndex),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: const Icon(Icons.shopping_cart_rounded),
        ),
        label: 'Cart',
      ),
      ..._destinations.skip(_cartIndex),
    ];

    return Scaffold(
      body: shell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shell.currentIndex != _cartIndex) const ViewCartBar(),
          NavigationBar(
            selectedIndex: shell.currentIndex,
            destinations: destinations,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
          ),
        ],
      ),
    );
  }
}
