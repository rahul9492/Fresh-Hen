import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/utils/open_link.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';

void main() {
  test('support number works however the admin typed it', () {
    for (final typed in ['9711739492', '+91 97117 39492', '+919711739492', '91-97117-39492']) {
      expect(supportDigits(typed), '919711739492', reason: typed);
      expect(supportDisplay(typed), '+91 97117 39492', reason: typed);
    }
  });

  test('store settings read the admin links and default to none', () {
    final s = StoreSettings.fromJson({
      'supportPhone': '9711739492',
      'termsUrl': 'https://freshhen.in/terms',
    });
    expect(s.termsUrl, 'https://freshhen.in/terms');
    expect(s.privacyUrl, isEmpty);
    expect(const StoreSettings().supportPhone, isEmpty);
  });
}
