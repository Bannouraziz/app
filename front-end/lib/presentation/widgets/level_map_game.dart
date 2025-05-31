import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/mock_users.dart';
import '../../domain/entities/question_model.dart';
import '../../services/auth_service.dart';
import '../../services/question_service.dart';
import '../../services/student_service.dart';
import 'level_circle.dart';

class LevelMapGame extends FlameGame with TapCallbacks {
  final QuestionService questionService;
  final AuthService authService;
  final StudentService studentService;

  SpriteComponent? background;
  bool isCurrentLevelCompleted = false;

  late SpriteComponent character;
  final List<LevelCircle> levels = [];
  List<Question>? currentQuestions;

  int currentLevel = 0;
  Map<String, dynamic>? overlayData;

  @override
  BuildContext? buildContext;

  bool _isHandlingTap = false;

  LevelMapGame(
    this.questionService, {
    required this.authService,
    required this.studentService,
  });

  void onLevelComplete(int completedLevel) {
    debugPrint('Level $completedLevel completed.');
    if (completedLevel != currentLevel + 1) {
      debugPrint(
          'Cannot progress: Completed level ($completedLevel) is not the current level (${currentLevel + 1})');
      return;
    }

    levels[currentLevel].isCompleted = true;
    isCurrentLevelCompleted = true;
    moveToNextLevel();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await MockUsers.loadSavedProgress();

    try {
      await images.load('map_background.jpg');
      await images.load('Bunnie.png');
      background = SpriteComponent()
        ..sprite = await loadSprite('map_background.jpg')
        ..size = size
        ..priority = 0;
      add(background!);
    } catch (e) {
      debugPrint('Failed to load background image: $e');
      background = SpriteComponent()
        ..size = size
        ..priority = 0;
      add(background!);
    }

    List<Vector2> levelPositions = [
      Vector2(260.w, size.y - 95.h),
      Vector2(190.w, size.y - 95.h),
      Vector2(130.w, size.y - 95.h),
      Vector2(55.w, size.y - 125.h),
      Vector2(100.w, size.y - 200.h),
      Vector2(173.w, size.y - 200.h),
      Vector2(270.w, size.y - 235.h),
      Vector2(180.w, size.y - 295.h),
      Vector2(100.w, size.y - 295.h),
      Vector2(105.w, size.y - 375.h),
      Vector2(190.w, size.y - 375.h),
      Vector2(85.w, size.y - 445.h),
      Vector2(240.w, size.y - 505.h),
      Vector2(90.w, size.y - 565.h),
    ];

    character = SpriteComponent()
      ..sprite = await loadSprite('Bunnie.png')
      ..size = Vector2(60, 60)
      ..position = levelPositions[0]
      ..priority = 1;
    add(character);

    for (int i = 0; i < levelPositions.length; i++) {
      final levelNumber = i + 1;

      final level = LevelCircle(
        position: levelPositions[i],
        radius: 16.r,
        questions: const [],
        levelNumber: levelNumber,
        priority: 2,
        onTap: (_) async {
          if (_isHandlingTap) {
            debugPrint('Already handling a tap, ignoring');
            return;
          }

          _isHandlingTap = true;
          debugPrint('Processing tap for Level $levelNumber');

          try {
            if (!levels[i].isAccessible) {
              debugPrint('Level $levelNumber is not accessible');
              return;
            }

            debugPrint('Fetching questions for level $levelNumber from API');
            try {
              final questionsData =
                  await questionService.getQuestionsForLevel(levelNumber);
              debugPrint('Received ${questionsData.length} questions from API');

              if (questionsData.isEmpty) {
                debugPrint('No questions available for level $levelNumber');
                ScaffoldMessenger.of(buildContext!).showSnackBar(const SnackBar(
                    content:
                        Text('Aucune question disponible pour ce niveau')));
                return;
              }

              // Convert the API response to Question objects
              currentQuestions = questionsData
                  .map((data) => Question(
                        id: data['_id'] ?? '',
                        text: data['question'] ?? '',
                        options: List<String>.from(data['choix'] ?? []),
                        correctAnswer: data['bonneReponse'] ?? '',
                        level: int.parse(data['niveau'] ?? '1'),
                        explanation: data['explication'] ?? '',
                      ))
                  .toList();

              debugPrint(
                  'Converted ${currentQuestions!.length} questions to Question objects');
            } catch (e) {
              debugPrint('Error fetching questions: $e');
              ScaffoldMessenger.of(buildContext!).showSnackBar(const SnackBar(
                  content: Text('Erreur lors du chargement des questions')));
              return;
            }

            overlayData = {
              'questions': currentQuestions,
              'onComplete': () {
                debugPrint('Level $levelNumber completed');
                onLevelComplete(levelNumber);
              },
            };

            overlays.add('QuestionOverlay');
          } finally {
            _isHandlingTap = false;
          }
        },
      );

      levels.add(level);
      add(level);
      debugPrint(
          'Level $levelNumber initialized. Accessible: ${level.isAccessible}');
    }

    try {
      final userData = await studentService.getProfile();
      debugPrint('User profile loaded: $userData');

      int userLevel = 0;
      List<bool> accessibleLevels = List.generate(levels.length, (i) => i == 0);
      List<bool> completedLevels = List.generate(levels.length, (i) => false);

      if (userData.containsKey('niveau')) {
        userLevel = userData['niveau'] is int
            ? userData['niveau']
            : int.tryParse(userData['niveau'].toString()) ?? 0;
      }

      // If we have accessibleLevels in the profile, use them
      if (userData.containsKey('accessibleLevels')) {
        try {
          final levelData = userData['accessibleLevels'];
          if (levelData is List) {
            accessibleLevels = levelData.cast<bool>();
          }
        } catch (e) {
          debugPrint('Error parsing accessibleLevels: $e');
        }
      }

      // If we have completedLevels in the profile, use them
      if (userData.containsKey('completedLevels')) {
        try {
          final levelData = userData['completedLevels'];
          if (levelData is List) {
            completedLevels = levelData.cast<bool>();
          }
        } catch (e) {
          debugPrint('Error parsing completedLevels: $e');
        }
      }

      currentLevel = userLevel;

      // Make sure we have valid lists of the right length
      if (accessibleLevels.length < levels.length) {
        accessibleLevels = List.generate(levels.length, (i) => i <= userLevel);
      }

      if (completedLevels.length < levels.length) {
        completedLevels = List.generate(levels.length, (i) => i < userLevel);
      }

      // Set accessible/completed state for each level
      for (int i = 0; i < levels.length; i++) {
        if (i < accessibleLevels.length) {
          levels[i].isAccessible = accessibleLevels[i];
        }

        if (i < completedLevels.length) {
          levels[i].isCompleted = completedLevels[i];
        }

        // Always make level 0 accessible and levels up to current level
        if (i <= currentLevel) {
          levels[i].isAccessible = true;
        }

        // Make all levels before current level completed
        if (i < currentLevel) {
          levels[i].isCompleted = true;
        }
      }

      // Position character at the current level
      if (currentLevel >= 0 && currentLevel < levels.length) {
        character.position = levels[currentLevel].position;
      }

      debugPrint(
          'Game state loaded successfully. Current level: $currentLevel');
    } catch (e) {
      debugPrint('Error loading game state: $e');
      // Set minimal game state - Level 1 accessible
      if (levels.isNotEmpty) {
        levels[0].isAccessible = true;
      }
    }
  }

  // Update level states based on backend response
  Future<void> updateLevelStates() async {
    try {
      final userData = await studentService.getProfile();
      debugPrint('Updating level states from profile: $userData');

      // Default values for levels if not available in userData
      int userLevel = currentLevel; // Start with current level as fallback

      // Try to extract level data from userData
      if (userData.containsKey('niveau')) {
        userLevel = userData['niveau'] is int
            ? userData['niveau']
            : int.tryParse(userData['niveau'].toString()) ?? currentLevel;
      }

      // Get level data from user profile
      List<bool> accessibleLevels = userData.containsKey('accessibleLevels') &&
              userData['accessibleLevels'] is List
          ? List<bool>.from(userData['accessibleLevels'])
          : List.generate(levels.length, (i) => i <= userLevel);

      List<bool> completedLevels = userData.containsKey('completedLevels') &&
              userData['completedLevels'] is List
          ? List<bool>.from(userData['completedLevels'])
          : List.generate(levels.length, (i) => i < userLevel);

      // If lists are too short, extend them
      if (accessibleLevels.length < levels.length) {
        accessibleLevels = [
          ...accessibleLevels,
          ...List.generate(
              levels.length - accessibleLevels.length, (i) => false)
        ];
      }

      if (completedLevels.length < levels.length) {
        completedLevels = [
          ...completedLevels,
          ...List.generate(levels.length - completedLevels.length, (i) => false)
        ];
      }

      // Update level states
      for (int i = 0; i < levels.length; i++) {
        if (i < accessibleLevels.length) {
          levels[i].isAccessible = accessibleLevels[i];
        }

        if (i < completedLevels.length) {
          levels[i].isCompleted = completedLevels[i];
        }
      }

      // Update current level
      if (userLevel != currentLevel) {
        currentLevel = userLevel;

        // Position character at the current level if visible
        if (currentLevel >= 0 && currentLevel < levels.length) {
          character.position = levels[currentLevel].position;
        }
      }

      debugPrint('Level states updated: currentLevel=$currentLevel');
    } catch (e) {
      debugPrint('Error updating level states: $e');
    }
  }

  void moveToNextLevel() {
    if (!isCurrentLevelCompleted) return;

    if (currentLevel < levels.length - 1) {
      levels[currentLevel].isCompleted = true;

      character.add(
        MoveEffect.to(
          levels[currentLevel + 1].position, // Move to next level position
          EffectController(duration: 1.0, curve: Curves.easeInOut),
        ),
      );

      // Then update level states
      currentLevel++;
      levels[currentLevel].isAccessible = true;
      isCurrentLevelCompleted = false;

      // Save progress
      studentService
          .saveLevel(
        currentLevel,
        levels.map((l) => l.isAccessible).toList(),
        levels.map((l) => l.isCompleted).toList(),
      )
          .then((_) {
        // After saving, update states from backend to ensure everything is in sync
        updateLevelStates();
      });

      // Play sound or show animation
      debugPrint('Advanced to level ${currentLevel}');
    } else {
      debugPrint('Already at max level ${levels.length - 1}');
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    background?.size = canvasSize;
  }
}
