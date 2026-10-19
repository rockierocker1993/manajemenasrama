/// Backend API configuration from `--dart-define`.
class BackendConfig {
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8877',
    //defaultValue: 'https://asrama-be.rockierocker.com',
  );

  static bool get isConfigured => baseUrl.isNotEmpty;
}
