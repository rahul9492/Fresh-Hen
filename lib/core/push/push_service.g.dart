// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Push notifications through Firebase Cloud Messaging. There is no in-app
/// notification list: pushes live in the system tray and tapping one opens the
/// screen from [pushRoute]. Features listen to [received] to refresh what a
/// push is about (e.g. orders); push never imports them.
///
/// Started from `FreshHenApp`. Until the Firebase config files are added
/// (`flutterfire configure`) it stays off and logs "Push disabled".

@ProviderFor(pushService)
final pushServiceProvider = PushServiceProvider._();

/// Push notifications through Firebase Cloud Messaging. There is no in-app
/// notification list: pushes live in the system tray and tapping one opens the
/// screen from [pushRoute]. Features listen to [received] to refresh what a
/// push is about (e.g. orders); push never imports them.
///
/// Started from `FreshHenApp`. Until the Firebase config files are added
/// (`flutterfire configure`) it stays off and logs "Push disabled".

final class PushServiceProvider
    extends $FunctionalProvider<PushService, PushService, PushService>
    with $Provider<PushService> {
  /// Push notifications through Firebase Cloud Messaging. There is no in-app
  /// notification list: pushes live in the system tray and tapping one opens the
  /// screen from [pushRoute]. Features listen to [received] to refresh what a
  /// push is about (e.g. orders); push never imports them.
  ///
  /// Started from `FreshHenApp`. Until the Firebase config files are added
  /// (`flutterfire configure`) it stays off and logs "Push disabled".
  PushServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushServiceHash();

  @$internal
  @override
  $ProviderElement<PushService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushService create(Ref ref) {
    return pushService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushService>(value),
    );
  }
}

String _$pushServiceHash() => r'd56bc943a906a8a23ef4ef29d7a23eef59cbc58c';
