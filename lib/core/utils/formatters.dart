import 'package:intl/intl.dart';

final _compact = NumberFormat.compact();

String rupees(int amount) => '₹$amount';

String compactCount(int count) => _compact.format(count);

String formatOrderDate(DateTime date) => DateFormat('d MMM, h:mm a').format(date);

/// "Just now", "12m ago", "3h ago", "Yesterday", or "5 Sep" for older dates.
String timeAgo(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 2) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(date);
}
