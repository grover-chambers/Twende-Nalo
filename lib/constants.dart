class Constants {
  // /api backend url
  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: '',
  );
}
