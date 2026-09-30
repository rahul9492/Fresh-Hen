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

  /// When true every repository provider returns its mock implementation.
  /// Flip the default to false once the backend is live.
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
}
