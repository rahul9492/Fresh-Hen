import 'package:intl/intl.dart';

final _compact = NumberFormat.compact();

String rupees(int amount) => '₹$amount';

String compactCount(int count) => _compact.format(count);

String formatOrderDate(DateTime date) => DateFormat('d MMM, h:mm a').format(date);
