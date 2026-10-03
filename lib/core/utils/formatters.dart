import 'package:intl/intl.dart';

final _compact = NumberFormat.compact();
final _indian = NumberFormat.decimalPattern('en_IN');

/// "₹320", "₹1,250", "₹1,25,000" (Indian digit grouping).
String rupees(int amount) => '₹${_indian.format(amount)}';

String compactCount(int count) => _compact.format(count);

/// "04 Sep, 4:28 pm", with the year added for dates outside the current year.
String formatOrderDate(DateTime date, {DateTime? now}) {
  final sameYear = date.year == (now ?? DateTime.now()).year;
  final day = DateFormat(sameYear ? 'dd MMM' : 'dd MMM yyyy').format(date);
  final time = DateFormat('h:mm').format(date);
  final period = DateFormat('a').format(date).toLowerCase();
  return '$day, $time $period';
}

/// "12 Jun 2024"
String formatFullDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

/// "10:00 AM"
String formatClock(DateTime time) => DateFormat('h:mm a').format(time);

/// "7-8 AM", "7:30-8:30 AM", "11 AM-12 PM": the period is written once when shared.
String formatTimeRange(DateTime start, DateTime end) {
  String clock(DateTime t) => DateFormat(t.minute == 0 ? 'h' : 'h:mm').format(t);
  final from = DateFormat('a').format(start);
  final to = DateFormat('a').format(end);
  return from == to ? '${clock(start)}-${clock(end)} $to' : '${clock(start)} $from-${clock(end)} $to';
}

/// "16 Oct"
String formatShortDate(DateTime date) => DateFormat('d MMM').format(date);

/// "Today", "Tomorrow", or "Sat 4 Oct".
String formatDayName(DateTime date, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final diff = _dateOnly(date).difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  return DateFormat('EEE d MMM').format(date);
}

/// "Delivered today at 4:37 PM", "Delivered yesterday at ...", "Delivered on 4 Sep at ...".
String formatDeliveredAt(DateTime date, {DateTime? now}) {
  final diff = _dateOnly(now ?? DateTime.now()).difference(_dateOnly(date)).inDays;
  final day = switch (diff) {
    0 => 'today',
    1 => 'yesterday',
    _ => 'on ${DateFormat('d MMM').format(date)}',
  };
  return 'Delivered $day at ${formatClock(date)}';
}

/// 45 -> "45 mins", 60 -> "1 hr", 90 -> "1:30 hrs".
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes mins';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return h == 1 ? '1 hr' : '$h hrs';
  return '$h:${m.toString().padLeft(2, '0')} hrs';
}

/// "45 mins - 1:30 hrs"
String formatEta(int minMinutes, int maxMinutes) =>
    '${formatMinutes(minMinutes)} - ${formatMinutes(maxMinutes)}';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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
