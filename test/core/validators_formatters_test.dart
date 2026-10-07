import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/utils/formatters.dart';
import 'package:fresh_hen/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('phone: ten digits starting 6-9', () {
      expect(Validators.isPhone('9876543210'), isTrue);
      expect(Validators.isPhone('6000000000'), isTrue);
      expect(Validators.isPhone('5876543210'), isFalse); // bad first digit
      expect(Validators.isPhone('987654321'), isFalse); // too short
      expect(Validators.isPhone('98765432100'), isFalse); // too long
      expect(Validators.isPhone('98765 43210'), isFalse);
      expect(Validators.isPhone(''), isFalse);
    });

    test('name: required and at least two characters', () {
      expect(Validators.name(null), 'Please enter your name');
      expect(Validators.name('   '), 'Please enter your name');
      expect(Validators.name('A'), 'Name is too short');
      expect(Validators.name(' Al '), isNull);
      expect(Validators.name('Rahul Kumar'), isNull);
    });

    test('email is optional but must look valid when given', () {
      expect(Validators.optionalEmail(null), isNull);
      expect(Validators.optionalEmail('  '), isNull);
      expect(Validators.optionalEmail('a@b.co'), isNull);
      expect(Validators.optionalEmail(' a@b.co '), isNull);
      expect(Validators.optionalEmail('a@b'), 'Enter a valid email address');
      expect(Validators.optionalEmail('a b@c.com'), 'Enter a valid email address');
      expect(Validators.optionalEmail('plain'), 'Enter a valid email address');
    });
  });

  group('money', () {
    test('rupees use Indian digit grouping', () {
      expect(rupees(0), '₹0');
      expect(rupees(320), '₹320');
      expect(rupees(1250), '₹1,250');
      expect(rupees(125000), '₹1,25,000');
    });

    test('compact counts', () {
      expect(compactCount(950), '950');
      expect(compactCount(12400), '12.4K');
    });
  });

  group('dates and times', () {
    final now = DateTime(2026, 10, 7, 12);

    test('order date drops the year inside the current year', () {
      expect(formatOrderDate(DateTime(2026, 9, 4, 16, 28), now: now), '04 Sep, 4:28 pm');
      expect(formatOrderDate(DateTime(2025, 9, 4, 9, 5), now: now), '04 Sep 2025, 9:05 am');
    });

    test('full, short and clock formats', () {
      expect(formatFullDate(DateTime(2024, 6, 12)), '12 Jun 2024');
      expect(formatShortDate(DateTime(2026, 10, 16)), '16 Oct');
      expect(formatClock(DateTime(2026, 1, 1, 10)), '10:00 AM');
      expect(formatClock(DateTime(2026, 1, 1, 16, 37)), '4:37 PM');
    });

    test('time ranges write the period once when shared', () {
      DateTime t(int h, [int m = 0]) => DateTime(2026, 1, 1, h, m);
      expect(formatTimeRange(t(7), t(8)), '7-8 AM');
      expect(formatTimeRange(t(7, 30), t(8, 30)), '7:30-8:30 AM');
      expect(formatTimeRange(t(11), t(12)), '11 AM-12 PM');
      expect(formatTimeRange(t(18), t(19)), '6-7 PM');
    });

    test('day names', () {
      expect(formatDayName(DateTime(2026, 10, 7, 23), now: now), 'Today');
      expect(formatDayName(DateTime(2026, 10, 8), now: now), 'Tomorrow');
      expect(formatDayName(DateTime(2026, 10, 10), now: now), 'Sat 10 Oct');
    });

    test('delivered-at wording', () {
      final at = DateTime(2026, 10, 7, 16, 37);
      expect(formatDeliveredAt(at, now: now), 'Delivered today at 4:37 PM');
      expect(
        formatDeliveredAt(DateTime(2026, 10, 6, 9), now: now),
        'Delivered yesterday at 9:00 AM',
      );
      expect(
        formatDeliveredAt(DateTime(2026, 9, 4, 9), now: now),
        'Delivered on 4 Sep at 9:00 AM',
      );
    });

    test('minutes and ETA', () {
      expect(formatMinutes(45), '45 mins');
      expect(formatMinutes(60), '1 hr');
      expect(formatMinutes(120), '2 hrs');
      expect(formatMinutes(90), '1:30 hrs');
      expect(formatMinutes(65), '1:05 hrs');
      expect(formatEta(45, 90), '45 mins - 1:30 hrs');
    });
  });
}
