import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/question_model.dart';
import '../../services/auth_service.dart';
import '../../services/question_service.dart';
import '../../services/student_service.dart'; 
import '../widgets/level_map_game.dart';
import 'question_page.dart';

class LevelMapPage extends StatefulWidget {
  final QuestionService questionService;

  const LevelMapPage({super.key, required this.questionService});

  @override
  State<LevelMapPage> createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> {
  late final LevelMapGame _game;

  @override
  void initState() {
    super.initState();
    _game = LevelMapGame(
      widget.questionService,
      authService: context.read<AuthService>(),
      studentService: context.read<StudentService>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(
              game: _game,
              overlayBuilderMap: {
                'QuestionOverlay': (BuildContext context, Object? _) {
                  final data = _game.overlayData;

                  if (data == null || data['questions'] == null || data['onComplete'] == null) {
                    debugPrint('Overlay data is incomplete or null.');
                    return const SizedBox.shrink();
                  }

                  final questions = (data['questions'] as List).cast<Question>();
                  final VoidCallback onComplete = data['onComplete'] as VoidCallback;

                  debugPrint('Displaying QuestionPage for level ${_game.currentLevel + 1}...');
                  return QuestionPage(
                    questions: questions,
                    onComplete: () {
                      onComplete();
                      _game.overlays.remove('QuestionOverlay');
                      setState(() {});
                    },
                    currentLevel: _game.currentLevel + 1,
                    game: _game,
                  );
                },
              },
            ),
          ],
        ),
      ),
    );
  }
}
