/// One page of a server-side list. Pages are zero-based in the app; the remote
/// repositories translate to whatever the API expects.
class Paginated<T> {
  const Paginated({required this.items, required this.page, required this.hasMore});

  final List<T> items;
  final int page;
  final bool hasMore;

  static Paginated<T> empty<T>() => Paginated<T>(items: const [], page: 0, hasMore: false);
}
