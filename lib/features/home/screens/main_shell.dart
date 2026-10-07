import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/lottie_nav_icon.dart';
import '../../cart/widgets/view_cart_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  StatefulNavigationShell get shell => widget.shell;

  /// 1 = bottom tabs fully shown, 0 = slid away. Scrolling down any tab hides
  /// them for more room; scrolling up (or reaching the top) brings them back.
  late final _nav = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );

  /// Scroll travelled in the current direction; hiding/showing waits for a
  /// little of it so tiny finger jitters don't make the bar flicker.
  double _travel = 0;

  static const _hideAfter = 24.0;
  static const _showAfter = 16.0;

  /// Near the top, or on a list too short to need the room: always shown.
  static const _topZone = 24.0;
  static const _shortList = 160.0;

  @override
  void didUpdateWidget(MainShell old) {
    super.didUpdateWidget(old);
    if (old.shell.currentIndex != shell.currentIndex) _setNav(true);
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  void _setNav(bool shown) {
    _travel = 0;
    final target = shown ? 1.0 : 0.0;
    if (_nav.value == target && !_nav.isAnimating) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _nav.value = target;
    } else {
      // Hiding is a touch slower and ends softly, so the bar eases away
      // instead of dropping off the screen.
      _nav.animateTo(
        target,
        duration: Duration(milliseconds: shown ? 420 : 650),
        curve: shown ? Curves.easeOutCubic : Curves.easeInOutQuad,
      );
    }
  }

  bool _onScroll(ScrollNotification n) {
    final m = n.metrics;
    if (m.axis != Axis.vertical) return false;
    if (m.pixels <= m.minScrollExtent + _topZone ||
        m.maxScrollExtent - m.minScrollExtent < _shortList) {
      if (n is ScrollUpdateNotification || n is ScrollEndNotification) _setNav(true);
      return false;
    }
    if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0;
      if (delta == 0) return false;
      // Changed direction: start counting afresh.
      if ((delta > 0) != (_travel > 0)) _travel = 0;
      _travel += delta;
      if (_travel > _hideAfter && _nav.value > 0) {
        _setNav(false);
      } else if (_travel < -_showAfter && _nav.value < 1) {
        _setNav(true);
      }
    }
    return false;
  }

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
        // Scrolls from any tab bubble up here to hide or show the bottom tabs.
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Stack(
            children: [
              _TabFade(index: shell.currentIndex, child: shell),
              // Sits at the bottom of the page, so it glides down as the tabs slide away.
              const Align(alignment: Alignment.bottomCenter, child: ViewCartBar()),
            ],
          ),
        ),
        // Shrinking the slot from the top makes the bar slide down off the screen,
        // and gives the page the freed-up space.
        bottomNavigationBar: SizeTransition(
          sizeFactor: _nav,
          alignment: Alignment.bottomCenter,
          // The bar fades out ahead of the shrinking space and slides a little,
          // so it dissolves rather than being squashed away.
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _nav,
              curve: const Interval(0.0, 0.9, curve: Curves.easeInOut),
            ),
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.6),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _nav, curve: Curves.easeInOut)),
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white, boxShadow: AppShadow.bar),
                child: NavigationBar(
                  selectedIndex: shell.currentIndex,
                  destinations: _destinations,
                  onDestinationSelected: (i) {
                    _setNav(true);
                    shell.goBranch(i, initialLocation: i == shell.currentIndex);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the tab content in each time the selected tab changes.
class _TabFade extends StatefulWidget {
  const _TabFade({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void didUpdateWidget(_TabFade old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0.35);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    child: widget.child,
  );
}
