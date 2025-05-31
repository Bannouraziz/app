import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'api_config.dart';

class ProgressService {
  final ApiService apiService;
  final SharedPreferences prefs;
  static const String _currentLevelKey = 'current_level';
  static const String _completedLevelsKey = 'completed_levels';

  ProgressService({
    required this.apiService,
    required this.prefs,
  });

  Future<Map<String, dynamic>> submitAnswer({
    required String studentId,
    required String questionId,
    required String answer,
  }) async {
    try {
      final response = await apiService.post(
        'api/reponses',
        {
          'eleveId': studentId,
          'questionId': questionId,
          'reponse': answer,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error submitting answer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    try {
      final response = await apiService.get('api/progression/$studentId');
      return response;
    } catch (e) {
      debugPrint('Error getting student progress: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await apiService.get(ApiConfig.progression);
      return response;
    } catch (e) {
      debugPrint('Error getting progress: $e');
      rethrow;
    }
  }

  Future<void> updateProgress(Map<String, dynamic> progressData) async {
    try {
      await apiService.put(
        ApiConfig.updateProgression,
        progressData,
      );
    } catch (e) {
      debugPrint('Error updating progress: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response =
          await apiService.get('${ApiConfig.progression}/achievements');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      rethrow;
    }
  }

  int getCurrentLevel() {
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  Future<void> setCurrentLevel(int level) async {
    await prefs.setInt(_currentLevelKey, level);
  }

  List<int> getCompletedLevels() {
    final String? completedLevelsStr = prefs.getString(_completedLevelsKey);
    if (completedLevelsStr == null) return [];
    return completedLevelsStr.split(',').map((e) => int.parse(e)).toList();
  }

  Future<void> addCompletedLevel(int level) async {
    final completedLevels = getCompletedLevels();
    if (!completedLevels.contains(level)) {
      completedLevels.add(level);
      await prefs.setString(_completedLevelsKey, completedLevels.join(','));
    }
  }

  Future<void> resetProgress() async {
    await prefs.remove(_currentLevelKey);
    await prefs.remove(_completedLevelsKey);
  }
}
