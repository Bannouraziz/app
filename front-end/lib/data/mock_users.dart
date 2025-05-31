import 'package:shared_preferences/shared_preferences.dart';

class MockUsers {
  static const List<Map<String, String>> users = [
    {
      'email': 'test@example.com',
      'password': 'password123',
      'fullName': 'Test User',
    },
    {
      'email': 'student@example.com',
      'password': 'student123',
      'fullName': 'Student User',
    },
    {
      'email': 'admin@example.com',
      'password': 'admin123',
      'fullName': 'Admin User',
    },
  ];

  static const Map<String, dynamic> mockUser = {
    'fullName': 'John Doe',
    'age': '10 ans',
    'level': 1,
  };

  static int _currentUserLevel = 1;

  static List<bool> _accessibleLevels = List.generate(14, (index) {
    print('Initializing level ${index + 1} accessibility: ${index < 3}');
    return index < 3;
  });

  static List<bool> _completedLevels = List.generate(14, (index) => false);

  static const String _currentLevelKey = 'currentLevel';
  static const String _accessibleLevelsKey = 'accessibleLevels';
  static const String _completedLevelsKey = 'completedLevels';

  static Future<void> loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserLevel = prefs.getInt(_currentLevelKey) ?? 1;

    final accessibleStr = prefs.getString(_accessibleLevelsKey);
    if (accessibleStr != null) {
      _accessibleLevels = accessibleStr.split(',').map((e) => e == 'true').toList();
    }

    final completedStr = prefs.getString(_completedLevelsKey);
    if (completedStr != null) {
      _completedLevels = completedStr.split(',').map((e) => e == 'true').toList();
    }

    if (_accessibleLevels.isNotEmpty) {
      _accessibleLevels[0] = true;
    }
  }

  static Future<Map<String, dynamic>> getMockLoginResponse(String email) async {
    await loadSavedProgress();
    final user = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => users[0],
    );

    return {
      'token': 'mock_token_${user['email']}',
      'user': {
        'id': '1',
        'email': user['email'],
        'fullName': user['fullName'],
        'role': 'student',
        'level': _currentUserLevel,
        'progress': 0.0,
        'accessibleLevels': _accessibleLevels,
        'completedLevels': _completedLevels,
      },
    };
  }

  static Object progressToNextLevel(String email, int completedLevel) {
    if (completedLevel < 1 || completedLevel >= 14) {
      return {'error': 'Invalid level'};
    }

    print('Before progression - Current level: $_currentUserLevel');
    print('Before progression - Accessible levels: $_accessibleLevels');

    _currentUserLevel = completedLevel + 1;
    if (completedLevel < 13) {
      _accessibleLevels[_currentUserLevel - 1] = true;
    }
    _completedLevels[completedLevel - 1] = true;

    return getMockLoginResponse(email);
  }

  static void resetProgress() {
    _currentUserLevel = 1;
    _accessibleLevels = List.generate(14, (index) => index == 0);
    _completedLevels = List.generate(14, (index) => false);
  }
}
