class AppConfig {
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';
  static const int apiTimeout = 30000; // 30 seconds
  static const String appName = 'Educational App';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String studentsEndpoint = '/students';
  static const String questionsEndpoint = '/questions';
  static const String progressEndpoint = '/progress';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
}
