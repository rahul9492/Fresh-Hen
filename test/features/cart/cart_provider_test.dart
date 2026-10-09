import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';

import '../../support/fixtures.dart';

CartLine _line(String productId, String variantId, int price, {int quantity = 1}) =>
    CartLine.fromVariant(product(productId), variant(variantId, price)).copyWith(quantity: quantity);

void main() {
  test("a pack's order limit caps +, re-adding and reorders, and tells the customer", () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    final limited = _line('a', '1', 100).copyWith(maxQuantity: 2);

    cart.add(limited);
    cart.increment('a:1');
    expect(c.read(cartLimitProvider), isNull);
    cart.increment('a:1'); // already at 2
    cart.add(limited);
    expect(c.read(cartProvider).single.quantity, 2);
    expect(c.read(cartLimitProvider)?.message, contains('up to 2'));

    cart.clear();
    cart.addAll([limited.copyWith(quantity: 5)]);
    expect(c.read(cartProvider).single.quantity, 2);
  });

  test('adding a new pack appends it; adding it again raises the quantity', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);

    cart.add(_line('a', '1', 100));
    cart.add(_line('b', '1', 50));
    cart.add(_line('a', '1', 100));

    final lines = c.read(cartProvider);
    expect(lines.map((l) => l.id), ['a:1', 'b:1']);
    expect(lines.first.quantity, 2);
  });

  test('addAll tops up lines already in the cart and adds the rest', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.add(_line('a', '1', 100));

    cart.addAll([_line('a', '1', 100, quantity: 2), _line('b', '1', 50, quantity: 3)]);

    final lines = c.read(cartProvider);
    expect(lines.firstWhere((l) => l.id == 'a:1').quantity, 3);
    expect(lines.firstWhere((l) => l.id == 'b:1').quantity, 3);
  });

  test('decrementing the last unit removes the line, never goes to zero', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.add(_line('a', '1', 100, quantity: 2));

    cart.decrement('a:1');
    expect(c.read(cartProvider).single.quantity, 1);
    cart.decrement('a:1');
    expect(c.read(cartProvider), isEmpty);
    cart.decrement('a:1'); // already gone: harmless
    expect(c.read(cartProvider), isEmpty);
  });

  test('increment and decrement only touch the line they name', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.addAll([_line('a', '1', 100), _line('b', '1', 50)]);

    cart.increment('b:1');

    expect(c.read(cartProvider).map((l) => l.quantity), [1, 2]);
  });

  test('selecting another pack swaps it but keeps add-ons and other products', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    final hen = product('hen', variants: [variant('500', 200), variant('1000', 380)]);
    cart.add(CartLine.fromVariant(hen, hen.variants[0]));
    cart.add(_line('other', '1', 50));
    cart.add(const CartLine(
      id: 'addon:m',
      productId: 'hen',
      name: 'Masala',
      unitLabel: '100 g',
      image: 'x',
      unitPrice: 80,
      isAddon: true,
    ));

    cart.selectVariant(hen, hen.variants[1]);

    final ids = c.read(cartProvider).map((l) => l.id).toList();
    expect(ids, containsAll(['other:1', 'addon:m', 'hen:1000']));
    expect(ids, isNot(contains('hen:500')));

    // Picking the pack that is already there changes nothing.
    cart.selectVariant(hen, hen.variants[1]);
    expect(c.read(cartProvider).length, 3);
  });

  test('clear empties the cart; restoreAll puts it back only into an empty cart', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.addAll([_line('a', '1', 100), _line('b', '1', 50)]);
    final before = c.read(cartProvider);

    cart.clear();
    expect(c.read(cartProvider), isEmpty);
    cart.restoreAll(before);
    expect(c.read(cartProvider), before);

    // Something was added meanwhile: Undo must not overwrite it.
    cart.clear();
    cart.add(_line('c', '1', 10));
    cart.restoreAll(before);
    expect(c.read(cartProvider).map((l) => l.id), ['c:1']);
  });

  test('restore puts a line back at its index and ignores duplicates', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.addAll([_line('a', '1', 100), _line('b', '1', 50), _line('c', '1', 20)]);
    final removed = c.read(cartProvider)[1];
    cart.removeAll({removed.id});
    expect(c.read(cartProvider).map((l) => l.id), ['a:1', 'c:1']);

    cart.restore(removed, 1);
    expect(c.read(cartProvider).map((l) => l.id), ['a:1', 'b:1', 'c:1']);

    cart.restore(removed, 0); // already there
    expect(c.read(cartProvider).length, 3);

    cart.removeAll({'c:1'});
    cart.restore(_line('z', '1', 5), 99); // index past the end is clamped
    expect(c.read(cartProvider).last.id, 'z:1');
  });

  test('removeAll drops several lines at once', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    final cart = c.read(cartProvider.notifier);
    cart.addAll([_line('a', '1', 1), _line('b', '1', 1), _line('c', '1', 1)]);
    cart.removeAll({'a:1', 'c:1'});
    expect(c.read(cartProvider).map((l) => l.id), ['b:1']);
  });

  group('derived values', () {
    test('summary counts units and sums the total across lines', () async {
      final (c, _) = await makeContainer();
      addTearDown(c.dispose);
      expect(c.read(cartSummaryProvider).isEmpty, isTrue);

      c.read(cartProvider.notifier).addAll([
        _line('a', '1', 100, quantity: 2),
        _line('b', '1', 50, quantity: 3),
      ]);

      final s = c.read(cartSummaryProvider);
      expect(s.itemCount, 5);
      expect(s.itemTotal, 350);
    });

    test('quantity per product adds up its packs; per line only that line', () async {
      final (c, _) = await makeContainer();
      addTearDown(c.dispose);
      final hen = product('hen', variants: [variant('500', 200), variant('1000', 380)]);
      c.read(cartProvider.notifier).addAll([
        CartLine.fromVariant(hen, hen.variants[0]).copyWith(quantity: 2),
        CartLine.fromVariant(hen, hen.variants[1]),
      ]);

      expect(c.read(productQuantityProvider('hen')), 3);
      expect(c.read(productQuantityProvider('none')), 0);
      expect(c.read(lineQuantityProvider('hen:500')), 2);
      expect(c.read(lineQuantityProvider('hen:1000')), 1);
      expect(c.read(lineQuantityProvider('missing')), 0);
    });
  });

  group('persistence', () {
    test('is saved per phone, and removed when emptied', () async {
      final (c, prefs) = await makeContainer();
      addTearDown(c.dispose);
      final cart = c.read(cartProvider.notifier);

      cart.add(_line('a', '1', 100));
      expect(prefs.getString('cart.$testPhone'), isNotNull);
      expect(prefs.getString('cart.guest'), isNull);

      cart.clear();
      expect(prefs.containsKey('cart.$testPhone'), isFalse);
    });

    test('a guest cart is kept under the guest key', () async {
      final (c, prefs) = await makeContainer(signedIn: false);
      addTearDown(c.dispose);
      c.read(cartProvider.notifier).add(_line('a', '1', 100));
      expect(prefs.getString('cart.guest'), isNotNull);
    });

    test('is restored from the device', () async {
      final saved = jsonEncode([_line('a', '1', 100, quantity: 2).toJson()]);
      final (c, _) = await makeContainer(prefs: {'cart.$testPhone': saved});
      addTearDown(c.dispose);
      expect(c.read(cartProvider).single.quantity, 2);
    });

    test('one customer cart is not shown to another', () async {
      final saved = jsonEncode([_line('a', '1', 100).toJson()]);
      final (c, _) = await makeContainer(prefs: {'cart.1111111111': saved});
      addTearDown(c.dispose);
      expect(c.read(cartProvider), isEmpty);
    });

    test('corrupt saved data starts an empty cart instead of crashing', () async {
      final (c, _) = await makeContainer(prefs: {'cart.$testPhone': '{not json'});
      addTearDown(c.dispose);
      expect(c.read(cartProvider), isEmpty);

      final (c2, _) = await makeContainer(prefs: {'cart.$testPhone': '"a string"'});
      addTearDown(c2.dispose);
      expect(c2.read(cartProvider), isEmpty);
    });

    test('a cart saved before lines carried a pack id recovers it from the line id', () async {
      final legacy = _line('hen', '500', 200).toJson()..remove('variantId');
      final (c, _) = await makeContainer(prefs: {'cart.$testPhone': jsonEncode([legacy])});
      addTearDown(c.dispose);
      expect(c.read(cartProvider).single.variantId, '500');
    });

    test('add-ons never get a recovered pack id', () async {
      final addon = const CartLine(
        id: 'addon:m',
        productId: 'm',
        name: 'M',
        unitLabel: '1',
        image: 'x',
        unitPrice: 1,
        isAddon: true,
      ).toJson();
      final (c, _) = await makeContainer(prefs: {'cart.$testPhone': jsonEncode([addon])});
      addTearDown(c.dispose);
      expect(c.read(cartProvider).single.variantId, isNull);
    });
  });
}
