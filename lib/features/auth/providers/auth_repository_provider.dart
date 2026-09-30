import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/prefs_provider.dart';
import '../../../core/storage/token_store.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/remote_auth_repository.dart';

part 'auth_repository_provider.g.dart';

/// The only place that decides mock vs remote for auth.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  if (Env.useMock) return MockAuthRepository(prefs);
  return RemoteAuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider), prefs);
}
