import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_store.g.dart';

/// Holds the API access and refresh tokens in the platform keystore
/// (Android Keystore / iOS Keychain).
///
/// The secure storage API is async, but request interceptors and session
/// restore need the token synchronously. So the tokens are loaded once at
/// startup ([load]) and kept in memory; every change is written through.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  String? _access;
  String? _refresh;

  String? get accessToken => _access;

  String? get refreshToken => _refresh;

  /// Reads persisted tokens into memory. Call once before `runApp`.
  Future<void> load() async {
    try {
      _access = await _storage.read(key: _accessKey);
      _refresh = await _storage.read(key: _refreshKey);
    } catch (_) {
      // Unreadable keystore (e.g. restored backup): treat as signed out.
      _access = null;
      _refresh = null;
    }
  }

  Future<void> save({required String access, String? refresh}) async {
    _access = access;
    if (refresh != null) _refresh = refresh;
    await _storage.write(key: _accessKey, value: access);
    if (refresh != null) await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      // Memory is already cleared; nothing more to do.
    }
  }
}

/// Overridden in `main()` with an instance whose tokens are already loaded.
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => throw UnimplementedError();
