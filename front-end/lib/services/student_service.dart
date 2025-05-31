import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../data/mock_users.dart';
import 'api_config.dart';
import 'api_service.dart';

class StudentService {
  final ApiService apiService;
  final SharedPreferences prefs;
  static const String _currentLevelKey = 'current_level';
  static const String _accessibleLevelsKey = 'accessible_levels';
  static const String _completedLevelsKey = 'completed_levels';

  StudentService({
    required this.apiService,
    required this.prefs,
  });

  Future<Map<String, dynamic>> registerStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        ApiConfig.register,
        {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error registering student: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        ApiConfig.login,
        {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error logging in student: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await prefs.remove('auth_token');
      apiService.clearToken();
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      debugPrint('Fetching profile data...');
      final token = prefs.getString('auth_token');
      debugPrint(
          'Using token: ${token != null ? 'Token exists' : 'No token found'}');

      // Get the user ID from preferences
      final userId = prefs.getString('user_id');
      debugPrint('User ID: $userId');

      if (token == null) {
        debugPrint('Authentication token not found, using fallback data');
        return _getFallbackProfileData();
      }

      try {
        debugPrint('Calling API for profile: ${ApiConfig.eleveProfile}');
        final response = await apiService.get(ApiConfig.eleveProfile);
        debugPrint('Profile API Response: $response');

        if (response == null || response.isEmpty) {
          debugPrint('Empty response from server, using fallback data');
          // Return fallback data if API fails
          return _getFallbackProfileData();
        }

        // Combine nom and prenom into nomComplet if they exist
        if (response['nom'] != null && response['prenom'] != null) {
          response['nomComplet'] = '${response['nom']} ${response['prenom']}';
          debugPrint('Created nomComplet: ${response['nomComplet']}');
        }

        // Make sure level exists for game progression
        if (!response.containsKey('niveau')) {
          debugPrint('No level found in profile, setting default to 0');
          response['niveau'] = 0; // Default level
        } else {
          debugPrint('User level from API: ${response['niveau']}');
        }

        // Check age data
        if (response.containsKey('age')) {
          debugPrint('User age from API: ${response['age']}');
          // Store age in preferences for question service
          prefs.setInt('ageUtilisateur', response['age'] ?? 10);
        } else {
          debugPrint('No age found in profile, using default');
          response['age'] = 10;
        }

        // Log available levels
        if (response.containsKey('accessibleLevels')) {
          debugPrint('Accessible levels: ${response['accessibleLevels']}');
        }

        // Store profile in preferences for offline access
        prefs.setString('profile_data', jsonEncode(response));
        debugPrint('Profile data saved to preferences');

        return response;
      } catch (apiError) {
        debugPrint('API Error: $apiError, trying to use cached profile');
        // Try to use cached profile data
        final cachedProfile = prefs.getString('profile_data');
        if (cachedProfile != null) {
          debugPrint('Using cached profile data');
          return jsonDecode(cachedProfile);
        }
        // If no cached data, use fallback
        debugPrint('No cached profile, using fallback');
        return _getFallbackProfileData();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return _getFallbackProfileData();
    }
  }

  // Fallback profile data when API fails
  Map<String, dynamic> _getFallbackProfileData() {
    return {
      'nomComplet': 'Utilisateur',
      'niveau': 0,
      'age': 10,
      'accessibleLevels': List.generate(14, (i) => i <= 0),
      'completedLevels': List.generate(14, (i) => false),
    };
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      await apiService.put(
        ApiConfig.updateEleve,
        profileData,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> saveLevel(int level, List<bool> accessibleLevels,
      List<bool> completedLevels) async {
    try {
      debugPrint(
          'Saving level progress: level=$level, accessibleLevels=${accessibleLevels.length}, completedLevels=${completedLevels.length}');

      // Save locally
      await prefs.setInt(_currentLevelKey, level);
      await prefs.setString(_accessibleLevelsKey,
          accessibleLevels.map((e) => e.toString()).join(','));
      await prefs.setString(_completedLevelsKey,
          completedLevels.map((e) => e.toString()).join(','));

      // Also save to backend
      try {
        final token = prefs.getString('auth_token');
        if (token == null) {
          debugPrint('No token available, skipping backend save');
          return;
        }

        // Update levels in the backend
        final response = await apiService.post(
          'eleves/update-progress',
          {
            'level': level,
            'accessibleLevels': accessibleLevels,
            'completedLevels': completedLevels,
          },
        );

        debugPrint('Backend save result: $response');
      } catch (apiError) {
        debugPrint('Error saving progress to backend: $apiError');
        // Continue even if backend save fails - we've saved locally
      }
    } catch (e) {
      debugPrint('Error in saveLevel: $e');
    }
  }

  // Get saved level progress from local storage
  Future<Map<String, dynamic>> getSavedProgress() async {
    final level = prefs.getInt(_currentLevelKey) ?? 0;

    List<bool> accessibleLevels = [];
    List<bool> completedLevels = [];

    try {
      final accessibleStr = prefs.getString(_accessibleLevelsKey);
      if (accessibleStr != null && accessibleStr.isNotEmpty) {
        accessibleLevels = accessibleStr
            .split(',')
            .map((e) => e.toLowerCase() == 'true')
            .toList();
      }

      final completedStr = prefs.getString(_completedLevelsKey);
      if (completedStr != null && completedStr.isNotEmpty) {
        completedLevels = completedStr
            .split(',')
            .map((e) => e.toLowerCase() == 'true')
            .toList();
      }
    } catch (e) {
      debugPrint('Error parsing saved progress: $e');
    }

    // Default values if nothing was saved
    if (accessibleLevels.isEmpty) {
      accessibleLevels = List.generate(14, (i) => i <= level);
    }

    if (completedLevels.isEmpty) {
      completedLevels = List.generate(14, (i) => i < level);
    }

    return {
      'level': level,
      'accessibleLevels': accessibleLevels,
      'completedLevels': completedLevels,
    };
  }
}
