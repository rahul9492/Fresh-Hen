import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../errors/app_exception.dart';
import 'small_widgets.dart';
import '../constants/spacing.dart';

/// Error state with a Retry button. Used by [AsyncView] and list screens.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = error is AppException && (error as AppException).message.contains('internet');
    return EmptyState(
      icon: offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
      title: offline ? 'No internet connection' : 'Something went wrong',
      message: offline ? 'Check your connection and try again.' : errorMessage(error),
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
    );
  }
}
