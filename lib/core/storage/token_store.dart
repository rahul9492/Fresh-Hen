import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';

part 'token_store.g.dart';

/// Persists the API access token. Backed by SharedPreferences for now; swap the
/// internals for `flutter_secure_storage` before release without touching callers.
class TokenStore {
  TokenStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'auth.token';

  String? read() => _prefs.getString(_key);

  Future<void> save(String token) => _prefs.setString(_key, token);

  Future<void> clear() => _prefs.remove(_key);
}

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore(ref.watch(sharedPrefsProvider));
