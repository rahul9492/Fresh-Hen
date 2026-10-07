import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A signed-in customer, for providers keyed by phone number.
class SignedIn extends AuthSession {
  @override
  AppUser? build() => const AppUser(phone: '9876543210', name: 'Rahul Kumar');
}

const testPhone = '9876543210';

/// Small catalog fixtures, so logic tests don't depend on the mock catalog.
ProductVariant variant(String id, int price, {int? mrp, bool inStock = true, String? label}) =>
    ProductVariant(id: id, label: label ?? id, price: price, mrp: mrp, inStock: inStock);

Product product(
  String id, {
  String categoryId = 'chicken',
  List<ProductVariant>? variants,
  double rating = 4.0,
  int ratingCount = 10,
  bool isPopular = false,
  bool isRecommended = false,
  List<Accompaniment> accompaniments = const [],
}) => Product(
  id: id,
  name: id,
  categoryId: categoryId,
  image: 'img-$id',
  rating: rating,
  ratingCount: ratingCount,
  variants: variants ?? [variant('v1', 100)],
  accompaniments: accompaniments,
  isPopular: isPopular,
  isRecommended: isRecommended,
);

/// A container with an empty device store; [signedIn] controls the session.
Future<(ProviderContainer, SharedPreferences)> makeContainer({
  Map<String, Object> prefs = const {},
  bool signedIn = true,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(store),
      if (signedIn) authSessionProvider.overrideWith(SignedIn.new),
      ...overrides,
    ],
  );
  return (c, store);
}
