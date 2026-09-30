import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import 'small_widgets.dart';

/// Error state with a Retry button. Used by [AsyncView] and list screens.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Could not load',
      message: errorMessage(error),
      action: onRetry == null
          ? null
          : OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
    );
  }
}
