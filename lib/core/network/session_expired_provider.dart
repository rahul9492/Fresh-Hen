import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_expired_provider.g.dart';

/// Bumped by the network layer when the server rejects the token (401).
/// The auth feature listens to this and signs the user out.
@Riverpod(keepAlive: true)
class SessionExpired extends _$SessionExpired {
  @override
  int build() => 0;

  void notify() => state++;
}
