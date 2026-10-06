import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';

/// Keeps order screens up to date without relying on push: while [active]
/// (an order is still on its way), quietly re-checks the orders every [every],
/// and also whenever the app comes back to the foreground. So when the store
/// taps "Being prepared" or "Out for delivery" in the admin app, the customer
/// sees it within moments even if a push never arrives.
///
/// Checks only while this screen is actually showing: not when another page
/// covers it, its tab is in the background, or the app is minimised.
class LiveOrderRefresh extends ConsumerStatefulWidget {
  const LiveOrderRefresh({
    super.key,
    required this.active,
    required this.child,
    this.every = const Duration(seconds: 20),
  });

  final bool active;
  final Widget child;
  final Duration every;

  @override
  ConsumerState<LiveOrderRefresh> createState() => _LiveOrderRefreshState();
}

class _LiveOrderRefreshState extends ConsumerState<LiveOrderRefresh> {
  Timer? _timer;
  late final AppLifecycleListener _lifecycle;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _foreground = true;
        // Back in the app: catch up on anything that changed meanwhile.
        if (widget.active) _refresh();
        _sync();
      },
      onHide: () {
        _foreground = false;
        _sync();
      },
    );
    _sync();
  }

  @override
  void didUpdateWidget(LiveOrderRefresh old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active || old.every != widget.every) {
      _timer?.cancel();
      _timer = null;
      _sync();
    }
  }

  void _sync() {
    final run = widget.active && _foreground;
    if (run && _timer == null) {
      _timer = Timer.periodic(widget.every, (_) {
        if (_visible) _refresh();
      });
    } else if (!run) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// On top (no page pushed over it) and in the selected tab.
  bool get _visible =>
      mounted && (ModalRoute.of(context)?.isCurrent ?? true) && TickerMode.valuesOf(context).enabled;

  void _refresh() => ref.read(ordersProvider.notifier).refreshQuietly();

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
