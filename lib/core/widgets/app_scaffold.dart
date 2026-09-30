import 'package:flutter/material.dart';

import 'loading_overlay.dart';

/// Standard screen frame: app bar, optional pull-to-refresh, blocking loader
/// and a pinned bottom bar. Keeps screens consistent and short.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.onRefresh,
    this.loading = false,
    this.backgroundColor,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  final Future<void> Function()? onRefresh;
  final bool loading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = onRefresh == null ? body : RefreshIndicator(onRefresh: onRefresh!, child: body);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions, backgroundColor: backgroundColor),
      body: LoadingOverlay(loading: loading, child: content),
      bottomNavigationBar: bottom,
    );
  }
}
