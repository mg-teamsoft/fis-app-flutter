class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Read timeouts from environment with defaults
  static final int connectTimeoutMs = int.tryParse(
        const String.fromEnvironment(
          'CONNECT_TIMEOUT_MS',
          defaultValue: '15000',
        ),
      ) ??
      15000;

  static final int receiveTimeoutMs = int.tryParse(
        const String.fromEnvironment(
          'RECEIVE_TIMEOUT_MS',
          defaultValue: '20000',
        ),
      ) ??
      20000;
}
