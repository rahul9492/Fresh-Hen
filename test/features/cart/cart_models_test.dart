import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';

import '../../support/fixtures.dart';

void main() {
  group('CartLine', () {
    test('built from a pack: id, price and MRP come from the pack', () {
      final p = product('hen', variants: [variant('500g', 200, mrp: 250, label: '500 g')]);
      final line = CartLine.fromVariant(p, p.variants.first);
      expect(line.id, 'hen:500g');
      expect(line.productId, 'hen');
      expect(line.variantId, '500g');
      expect(line.unitLabel, '500 g');
      expect(line.unitPrice, 200);
      expect(line.unitMrp, 250);
      expect(line.quantity, 1);
      expect(line.isAddon, isFalse);
    });

    test('built from an add-on: flagged, with no pack id', () {
      const addon = Accompaniment(
        id: 'masala',
        name: 'Masala',
        weight: '100 g',
        price: 80,
        rating: 4.5,
        ratingCount: 10,
        image: 'x',
      );
      final line = CartLine.fromAccompaniment(addon);
      expect(line.id, 'addon:masala');
      expect(line.isAddon, isTrue);
      expect(line.variantId, isNull);
      expect(line.unitPrice, 80);
    });

    test('totals multiply by quantity', () {
      final line = CartLine.fromVariant(product('a'), variant('v', 120)).copyWith(quantity: 3);
      expect(line.total, 360);
    });

    test('a discount shows only when the MRP is above the price', () {
      final p = product('a');
      final discounted = CartLine.fromVariant(p, variant('v', 100, mrp: 150)).copyWith(quantity: 2);
      expect(discounted.mrpTotal, 300);
      expect(discounted.total, 200);
      expect(discounted.isDiscounted, isTrue);

      final noMrp = CartLine.fromVariant(p, variant('v', 100));
      expect(noMrp.mrpTotal, 100);
      expect(noMrp.isDiscounted, isFalse);

      final mrpBelow = CartLine.fromVariant(p, variant('v', 100, mrp: 80));
      expect(mrpBelow.mrpTotal, 100); // a lower MRP is ignored
      expect(mrpBelow.isDiscounted, isFalse);
    });

    test('survives a JSON round trip', () {
      final line =
          CartLine.fromVariant(product('a'), variant('v', 99, mrp: 120)).copyWith(quantity: 4);
      expect(CartLine.fromJson(line.toJson()), line);
    });
  });

  test('an empty summary has no items', () {
    expect(const CartSummary(itemCount: 0, itemTotal: 0).isEmpty, isTrue);
    expect(const CartSummary(itemCount: 2, itemTotal: 300).isEmpty, isFalse);
  });
}
