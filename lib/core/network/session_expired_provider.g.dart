// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_expired_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bumped by the network layer when the server rejects the token (401).
/// The auth feature listens to this and signs the user out.

@ProviderFor(SessionExpired)
final sessionExpiredProvider = SessionExpiredProvider._();

/// Bumped by the network layer when the server rejects the token (401).
/// The auth feature listens to this and signs the user out.
final class SessionExpiredProvider
    extends $NotifierProvider<SessionExpired, int> {
  /// Bumped by the network layer when the server rejects the token (401).
  /// The auth feature listens to this and signs the user out.
  SessionExpiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionExpiredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionExpiredHash();

  @$internal
  @override
  SessionExpired create() => SessionExpired();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionExpiredHash() => r'74a62641ecae93c2e5648a0cfde9dbf6c95356e7';

/// Bumped by the network layer when the server rejects the token (401).
/// The auth feature listens to this and signs the user out.

abstract class _$SessionExpired extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
