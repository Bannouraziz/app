import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String get baseUrl {
    // Check if we have a custom URL stored in preferences
    SharedPreferences.getInstance().then((prefs) {
      final customUrl = prefs.getString('custom_api_url');
      if (customUrl != null && customUrl.isNotEmpty) {
        debugPrint('Using custom API URL: $customUrl');
        return customUrl;
      }
    }).catchError((e) {
      debugPrint('Error reading custom API URL: $e');
    });

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Try multiple possible Android endpoints
      // The Android emulator uses 10.0.2.2 to access the host machine's localhost
      try {
        return 'http://10.0.2.2:3000/api'; // Android emulator default
      } catch (e) {
        debugPrint('Error using 10.0.2.2: $e');
        try {
          return 'http://192.168.1.3:3000/api'; // Common local network IP
        } catch (e) {
          debugPrint('Error using 192.168.1.3: $e');
          return 'http://localhost:3000/api'; // Last resort
        }
      }
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // Enable setting a custom API URL at runtime
  static Future<void> setCustomApiUrl(String url) async {
    if (url.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_api_url', url);
    debugPrint('Custom API URL set: $url');
  }

  // Auth endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // Student (Élève) endpoints
  static const String eleves = 'eleves';
  static const String eleveProfile = 'eleves/profile';
  static const String updateEleve = 'eleves/update';

  // Question endpoints
  static const String questions = 'questions';
  static const String questionById = 'questions/{id}';

  // Use this method to get a dynamic questions endpoint based on age and level
  static String getQuestionsEndpoint(int age, int niveau) {
    return 'questions/age/$age/niveau/$niveau';
  }

  // Response endpoints
  static const String reponses = 'reponses';
  static const String submitReponse = 'reponses/submit';

  // Progress endpoints
  static const String progression = 'progression';
  static const String updateProgression = 'progression/update';

  // Admin endpoints
  static const String adminLogin = 'admin/login';
  static const String adminRegister = 'admin/register';
}
