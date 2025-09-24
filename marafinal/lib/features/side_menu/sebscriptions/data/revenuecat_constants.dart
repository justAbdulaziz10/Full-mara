// Provided at build time via --dart-define=REVENUECAT_APPLE_API_KEY=xxxx
const appleApiKey = String.fromEnvironment(
  'REVENUECAT_APPLE_API_KEY',
  defaultValue: '',
);
