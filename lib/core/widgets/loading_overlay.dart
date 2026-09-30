import 'package:flutter/material.dart';

/// Blocks interaction and shows a spinner over [child] while [loading].
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.loading, required this.child});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading) ...const [
          Positioned.fill(child: ModalBarrier(dismissible: false, color: Color(0x66FFFFFF))),
          Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
