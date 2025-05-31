import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class QuestionService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  QuestionService({
    required ApiService apiService,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _prefs = prefs;

  Future<List<Map<String, dynamic>>> getQuestionsForLevel(int niveau) async {
    final token = _prefs.getString('auth_token');
    if (token == null) {
      debugPrint('Authentication token is missing');
      throw Exception('Non authentifié');
    }

    try {
      // First, get the student's profile to get the age
      debugPrint('Requesting profile data to get age...');
      final profileResponse = await http.get(
        Uri.parse('${_apiService.baseUrl}/eleves/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      int age = 10; // Default age
      try {
        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          debugPrint('Profile API response: $profileData');
          age = profileData['age'] ?? 10;
          debugPrint('Using age $age from profile');

          // Store age for future use
          _prefs.setInt('ageUtilisateur', age);
        } else {
          // Try to get age from local preferences if API fails
          age = _prefs.getInt('ageUtilisateur') ?? 10;
          debugPrint('Using locally stored age: $age');
        }
      } catch (profileError) {
        debugPrint('Error parsing profile: $profileError');
      }

      // Convert niveau to string to match database format
      final String niveauString = niveau.toString();

      debugPrint('Fetching questions for age=$age, niveau=$niveauString');

      // Try multiple API formats to ensure compatibility with backend
      List<Map<String, dynamic>> questions = [];
      bool success = false;

      // Array of different endpoint formats to try
      final endpoints = [
        // Format 1: Original path parameters
        '${_apiService.baseUrl}/questions/age/$age/niveau/$niveauString',

        // Format 2: Query parameters
        '${_apiService.baseUrl}/questions?age=$age&niveau=$niveauString',

        // Format 3: Different path structure
        '${_apiService.baseUrl}/questions/niveau/$niveauString/age/$age',

        // Format 4: Try without API version prefix
        '${_apiService.baseUrl.replaceAll('/api', '')}/questions/age/$age/niveau/$niveauString',
      ];

      // Try each endpoint format until one works
      for (final endpoint in endpoints) {
        debugPrint('Trying endpoint: $endpoint');

        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          debugPrint('Response from $endpoint: ${response.statusCode}');

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);

            // Check if it's an array
            if (responseData is List) {
              debugPrint('Got array response from: $endpoint');
              questions = responseData.cast<Map<String, dynamic>>();

              if (questions.isNotEmpty) {
                debugPrint('Found ${questions.length} questions!');
                success = true;
                // Remember successful format
                _prefs.setString('successful_question_endpoint', endpoint);
                break;
              } else {
                debugPrint('Empty array response from: $endpoint');
              }
            } else if (responseData is Map &&
                responseData.containsKey('questions')) {
              // Some APIs wrap the array in an object
              final questionList = responseData['questions'];
              if (questionList is List) {
                questions = questionList.cast<Map<String, dynamic>>();
                if (questions.isNotEmpty) {
                  debugPrint(
                      'Found ${questions.length} questions in nested format!');
                  success = true;
                  _prefs.setString('successful_question_endpoint', endpoint);
                  break;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error with endpoint $endpoint: $e');
        }
      }

      // If we found questions with any endpoint
      if (success) {
        // Save questions to local storage for offline access
        _prefs.setString('questions_level_$niveau', jsonEncode(questions));
        return questions;
      }

      // If all endpoints failed, check if we have a previously successful endpoint
      final lastSuccessfulEndpoint =
          _prefs.getString('successful_question_endpoint');
      if (lastSuccessfulEndpoint != null) {
        debugPrint(
            'Trying previously successful endpoint: $lastSuccessfulEndpoint');
        try {
          final response = await http.get(
            Uri.parse(lastSuccessfulEndpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data is List && data.isNotEmpty) {
              return data.cast<Map<String, dynamic>>();
            }
          }
        } catch (e) {
          debugPrint('Error with last successful endpoint: $e');
        }
      }

      // Try to get cached questions if all API calls fail
      final cachedQuestions = _prefs.getString('questions_level_$niveau');
      if (cachedQuestions != null) {
        debugPrint('Using cached questions for level $niveau');
        final data = json.decode(cachedQuestions);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }

      // If all else fails, return fallback questions
      return _getFallbackQuestions(niveau);
    } catch (e) {
      debugPrint('Error in getQuestionsForLevel: $e');
      // Return fallback questions for offline use
      return _getFallbackQuestions(niveau);
    }
  }

  // Fallback questions when API fails
  List<Map<String, dynamic>> _getFallbackQuestions(int niveau) {
    debugPrint('Using fallback questions for level $niveau');

    // Generate some basic questions based on the level
    return List.generate(
        3,
        (index) => {
              '_id': 'offline_${niveau}_$index',
              'question':
                  'Question ${index + 1} du niveau $niveau (mode hors ligne)',
              'choix': ['Option A', 'Option B', 'Option C', 'Option D'],
              'bonneReponse': 'Option A',
              'niveau': niveau.toString(),
              'age': '10',
              'explication': 'Ceci est une question générée en mode hors ligne'
            });
  }

  Future<List<Map<String, dynamic>>> getAvailableLevels() async {
    final token = _prefs.getString('auth_token');
    if (token == null) throw Exception('Non authentifié');

    try {
      debugPrint('Fetching available levels');
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/eleves/niveaux-disponibles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Levels response: ${response.body}');
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
            'Failed to get levels: ${response.statusCode} - ${response.body}');
        throw Exception('Error loading levels: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error in getAvailableLevels: $e');
      throw Exception('Error loading levels: $e');
    }
  }

  Future<Map<String, dynamic>> submitAnswers(
      int niveau, List<String> answers) async {
    final token = _prefs.getString('auth_token');
    if (token == null) throw Exception('Non authentifié');

    try {
      debugPrint('Submitting ${answers.length} answers for level $niveau');

      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/questions/niveau/$niveau/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'answers': answers}),
      );

      debugPrint('Submit response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('Submit response: $responseData');

        // Save user's level progress if level was completed
        if (responseData['levelCompleted'] == true) {
          try {
            // Update locally stored level if needed
            final currentLevel = _prefs.getInt('current_level') ?? 0;
            final nextLevel = responseData['nextLevel'] ?? (niveau + 1);

            if (nextLevel > currentLevel) {
              await _prefs.setInt('current_level', nextLevel);
              debugPrint('Updated local level to $nextLevel');
            }

            // If backend has accessibleLevels and completedLevels, save them
            if (responseData.containsKey('accessibleLevels') &&
                responseData.containsKey('completedLevels')) {
              await saveProgressToBackend(
                  nextLevel,
                  responseData['accessibleLevels'],
                  responseData['completedLevels']);
            }
          } catch (e) {
            debugPrint('Error saving level progress: $e');
          }
        }

        return responseData;
      } else {
        debugPrint(
            'Error submitting answers: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la soumission des réponses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in submitAnswers: $e');
      throw Exception('Erreur lors de la soumission des réponses: $e');
    }
  }

  // Send progress update to backend
  Future<void> saveProgressToBackend(int level, List<bool> accessibleLevels,
      List<bool> completedLevels) async {
    final token = _prefs.getString('auth_token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/eleves/update-progress'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'level': level,
          'accessibleLevels': accessibleLevels,
          'completedLevels': completedLevels,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Progress saved to backend successfully');
      } else {
        debugPrint(
            'Error saving progress to backend: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in saveProgressToBackend: $e');
    }
  }
}
