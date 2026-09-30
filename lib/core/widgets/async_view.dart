import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Custom loading state (e.g. a `ShimmerList`). Defaults to a spinner.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(error: error, onRetry: onRetry),
    );
  }
}
