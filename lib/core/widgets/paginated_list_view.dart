import 'package:flutter/material.dart';

/// Infinite-scroll list. Calls [onLoadMore] when the user nears the end and
/// shows a spinner footer while more pages remain. Pair with a `Paginated` state.
class PaginatedListView<T> extends StatelessWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.hasMore,
    required this.onLoadMore,
    this.isLoadingMore = false,
    this.onRefresh,
    this.padding = const EdgeInsets.all(16),
    this.separator = const SizedBox(height: 12),
    this.loadMoreThreshold = 240,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry padding;
  final Widget separator;
  final double loadMoreThreshold;

  @override
  Widget build(BuildContext context) {
    final list = NotificationListener<ScrollNotification>(
      onNotification: (n) {
        final nearEnd = n.metrics.extentAfter < loadMoreThreshold;
        if (nearEnd && hasMore && !isLoadingMore) onLoadMore();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => separator,
        itemBuilder: (context, i) {
          if (i >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
            );
          }
          return itemBuilder(context, items[i]);
        },
      ),
    );
    return onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
