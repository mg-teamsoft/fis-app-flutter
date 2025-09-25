class AppConfig {
  static const env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const mockOcr = bool.fromEnvironment(
    'MOCK_OCR',
    defaultValue: false,
  );
}