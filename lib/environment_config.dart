class EnvironmentConfig {
  static const ENV = String.fromEnvironment('ENV', defaultValue: 'DEV');
}