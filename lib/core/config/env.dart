/// Build-time configuration. Override with `--dart-define`:
///
/// ```
/// flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.example.com/v1
/// ```
abstract final class Env {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.freshhen.example/v1',
  );

  /// True in release builds (`flutter build`, profile and release modes).
  static const _isRelease = bool.fromEnvironment('dart.vm.product');

  /// When true every repository provider returns its mock implementation.
  /// Defaults to mock while developing, but a release build never falls back to
  /// mock (which would accept the fake OTP) unless `USE_MOCK=true` is passed.
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: !_isRelease);
}
