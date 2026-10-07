import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/repositories/address_repository.dart';

import '../../support/fixtures.dart';

Address _addr(
  String id, {
  bool isDefault = false,
  AddressLabel label = AddressLabel.home,
  String? customLabel,
  String landmark = '',
}) =>
    Address(
      id: id,
      label: label,
      customLabel: customLabel,
      house: 'Flat $id',
      area: 'Sector 62',
      landmark: landmark,
      city: 'Noida',
      pincode: '201301',
      name: 'Rahul',
      phone: '9876543210',
      isDefault: isDefault,
    );

class _FakeAddresses implements AddressRepository {
  _FakeAddresses([List<Address> start = const []]) : server = [...start];

  List<Address> server;
  bool fail = false;
  bool failReads = false;

  void _check() {
    if (fail) throw Exception('rejected');
  }

  @override
  Future<List<Address>> fetch() async {
    if (failReads) throw Exception('offline');
    return [...server];
  }

  @override
  Future<Address> create(Address address) async {
    _check();
    final saved = address.copyWith(id: 'server-${server.length + 1}');
    server = upsertAddress(server, saved);
    return saved;
  }

  @override
  Future<Address> update(Address address) async {
    _check();
    server = upsertAddress(server, address);
    return address;
  }

  @override
  Future<void> remove(String id) async {
    _check();
    server = server.where((a) => a.id != id).toList();
  }

  @override
  Future<void> makeDefault(String id) async {
    await Future<void>.delayed(Duration.zero); // the server takes a moment
    _check();
    server = [for (final a in server) a.copyWith(isDefault: a.id == id)];
  }
}

Future<(ProviderContainer, _FakeAddresses)> _setUp({
  List<Address> server = const [],
  Map<String, Object> prefs = const {},
  bool signedIn = true,
}) async {
  final repo = _FakeAddresses(server);
  final (c, _) = await makeContainer(
    prefs: prefs,
    signedIn: signedIn,
    overrides: [addressRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  c.listen(addressesProvider, (_, _) {});
  c.listen(selectedAddressIdProvider, (_, _) {});
  return (c, repo);
}

Future<void> _settle() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('Address', () {
    test('title is the label, or the custom name for Other', () {
      expect(_addr('1').title, 'Home');
      expect(_addr('1', label: AddressLabel.work).title, 'Work');
      expect(_addr('1', label: AddressLabel.other, customLabel: "Mom's place").title, "Mom's place");
      expect(_addr('1', label: AddressLabel.other, customLabel: '  ').title, 'Other');
      expect(_addr('1', label: AddressLabel.other).title, 'Other');
      // A custom name is only used for Other.
      expect(_addr('1', customLabel: 'Ignored').title, 'Home');
    });

    test('the one-line address adds the landmark only when given', () {
      expect(_addr('1').line, 'Flat 1, Sector 62, Noida - 201301');
      expect(
        _addr('1', landmark: ' Metro ').line,
        'Flat 1, Sector 62, Near Metro, Noida - 201301',
      );
      expect(_addr('1').fullText, 'Home • Flat 1, Sector 62, Noida - 201301');
    });

    test('survives a JSON round trip', () {
      final a = _addr('1', isDefault: true, landmark: 'Metro');
      expect(Address.fromJson(a.toJson()), a);
    });
  });

  group('list helpers', () {
    test('a new default clears the old one; a new non-default leaves it', () {
      final list = [_addr('1', isDefault: true), _addr('2')];
      final withNewDefault = upsertAddress(list, _addr('3', isDefault: true));
      expect(withNewDefault.where((a) => a.isDefault).map((a) => a.id), ['3']);

      final withPlain = upsertAddress(list, _addr('3'));
      expect(withPlain.where((a) => a.isDefault).map((a) => a.id), ['1']);
      expect(withPlain.map((a) => a.id), ['1', '2', '3']);
    });

    test('updating keeps the address where it was', () {
      final list = [_addr('1', isDefault: true), _addr('2'), _addr('3')];
      final updated = upsertAddress(list, _addr('2').copyWith(house: 'New'));
      expect(updated.map((a) => a.id), ['1', '2', '3']);
      expect(updated[1].house, 'New');
    });

    test('exactly one default whenever there is an address', () {
      expect(withOneDefault([]), isEmpty);
      expect(withOneDefault([_addr('1'), _addr('2')]).map((a) => a.isDefault), [true, false]);
      final already = [_addr('1'), _addr('2', isDefault: true)];
      expect(withOneDefault(already), already);
    });

    test('corrupt or missing saved data decodes to nothing instead of crashing', () {
      expect(decodeAddresses(null), isEmpty);
      expect(decodeAddresses('{not json'), isEmpty);
      expect(decodeAddresses('"text"'), isEmpty);
      expect(decodeAddresses('[1, 2]'), isEmpty);
      expect(decodeAddresses(encodeAddresses([_addr('1')])).single.id, '1');
    });
  });

  group('MockAddressRepository', () {
    test('keeps addresses per phone number, with one default', () async {
      final (_, prefs) = await makeContainer();
      String? phone = '111';
      final repo = MockAddressRepository(prefs, () => phone);

      await repo.create(_addr('a'));
      await repo.create(_addr('b'));
      expect((await repo.fetch()).map((a) => a.isDefault), [true, false]);

      await repo.makeDefault('b');
      expect((await repo.fetch()).map((a) => a.isDefault), [false, true]);

      await repo.update(_addr('a').copyWith(house: 'Changed', isDefault: false));
      expect((await repo.fetch()).first.house, 'Changed');

      await repo.remove('b');
      expect((await repo.fetch()).single.id, 'a');
      expect((await repo.fetch()).single.isDefault, isTrue); // default passes on

      phone = '222';
      expect(await repo.fetch(), isEmpty);
    });
  });

  group('Addresses provider', () {
    test('shows the cached copy at once, then the server list', () async {
      final cached = encodeAddresses([_addr('old', isDefault: true)]);
      final (c, _) = await _setUp(
        server: [_addr('new', isDefault: true)],
        prefs: {'addresses.cache.$testPhone': cached},
      );
      expect(c.read(addressesProvider).single.id, 'old');
      await _settle();
      expect(c.read(addressesProvider).single.id, 'new');
    });

    test('offline, the cached list stays', () async {
      final repo = _FakeAddresses()..failReads = true;
      final (c, _) = await makeContainer(
        prefs: {'addresses.cache.$testPhone': encodeAddresses([_addr('old', isDefault: true)])},
        overrides: [addressRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(addressesProvider, (_, _) {});
      await _settle();
      expect(c.read(addressesProvider).single.id, 'old');
    });

    test('a new address takes the id the server gave it and becomes the first default', () async {
      final (c, _) = await _setUp();
      await _settle();
      final saved = await c.read(addressesProvider.notifier).save(_addr('local'));
      expect(saved.id, startsWith('server-'));
      final list = c.read(addressesProvider);
      expect(list.single.id, saved.id);
      expect(list.single.isDefault, isTrue);
    });

    test('a rejected save rolls back and rethrows', () async {
      final (c, repo) = await _setUp(server: [_addr('1', isDefault: true)]);
      await _settle();
      repo.fail = true;
      await expectLater(
        c.read(addressesProvider.notifier).save(_addr('2')),
        throwsException,
      );
      expect(c.read(addressesProvider).map((a) => a.id), ['1']);
    });

    test('editing an address updates it in place', () async {
      final (c, _) = await _setUp(server: [_addr('1', isDefault: true), _addr('2')]);
      await _settle();
      await c.read(addressesProvider.notifier).save(_addr('2').copyWith(house: 'Edited'));
      expect(c.read(addressesProvider).map((a) => a.house), ['Flat 1', 'Edited']);
    });

    test('make default switches it; remove drops it; a rejection rolls back', () async {
      final (c, repo) = await _setUp(server: [_addr('1', isDefault: true), _addr('2')]);
      await _settle();
      final notifier = c.read(addressesProvider.notifier);

      await notifier.makeDefault('2');
      expect(c.read(addressesProvider).where((a) => a.isDefault).map((a) => a.id), ['2']);

      repo.fail = true;
      await expectLater(notifier.makeDefault('1'), throwsException);
      expect(c.read(addressesProvider).where((a) => a.isDefault).map((a) => a.id), ['2']);
      await expectLater(notifier.remove('2'), throwsException);
      expect(c.read(addressesProvider).length, 2);

      repo.fail = false;
      await notifier.remove('2');
      expect(c.read(addressesProvider).map((a) => a.id), ['1']);
      expect(c.read(addressesProvider).single.isDefault, isTrue); // default passes on
    });

    test('removing the default hands it to the next address', () async {
      final (c, _) = await _setUp(server: [_addr('1', isDefault: true), _addr('2')]);
      await _settle();
      await c.read(addressesProvider.notifier).remove('1');
      expect(c.read(addressesProvider).single.isDefault, isTrue);
    });

    test('a change made while the list is still loading is not undone by it', () async {
      final both = [_addr('1', isDefault: true), _addr('2')];
      final (c, _) = await _setUp(
        server: both,
        prefs: {'addresses.cache.$testPhone': encodeAddresses(both)},
      );
      // The first refresh is still in flight: change the default straight away.
      await c.read(addressesProvider.notifier).makeDefault('2');
      await _settle();
      expect(c.read(addressesProvider).where((a) => a.isDefault).map((a) => a.id), ['2']);
    });

    test('a guest does not load from the server', () async {
      final (c, _) = await _setUp(server: [_addr('1')], signedIn: false);
      await _settle();
      expect(c.read(addressesProvider), isEmpty);
    });
  });

  group('selected address', () {
    test('defaults to the default address, else the first', () async {
      final (c, _) = await _setUp(server: [_addr('1'), _addr('2', isDefault: true)]);
      await _settle();
      expect(c.read(selectedAddressIdProvider), '2');
      expect(c.read(selectedAddressProvider)?.id, '2');
    });

    test('is null when there are no addresses', () async {
      final (c, _) = await _setUp();
      await _settle();
      expect(c.read(selectedAddressIdProvider), isNull);
      expect(c.read(selectedAddressProvider), isNull);
    });

    test('a pick sticks, until that address is removed', () async {
      final (c, _) = await _setUp(server: [_addr('1', isDefault: true), _addr('2'), _addr('3')]);
      await _settle();
      c.read(selectedAddressIdProvider.notifier).select('3');
      expect(c.read(selectedAddressProvider)?.id, '3');

      // Another change to the list keeps the pick.
      await c.read(addressesProvider.notifier).makeDefault('2');
      expect(c.read(selectedAddressIdProvider), '3');

      // The picked address is deleted: fall back to the default.
      await c.read(addressesProvider.notifier).remove('3');
      expect(c.read(selectedAddressIdProvider), '2');
    });
  });
}
