import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/question_model.dart';
import '../../services/question_service.dart';
import '../widgets/level_map_game.dart';

class QuestionPage extends StatefulWidget {
  final List<Question>? questions;
  final VoidCallback onComplete;
  final int currentLevel;
  final LevelMapGame game; // Add this parameter to accept the game instance

  const QuestionPage({
    super.key,
    required this.questions,
    required this.onComplete,
    required this.currentLevel,
    required this.game, // Initialize the game parameter
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  late AnimationController progressController;
  late Animation<double> progressAnimation;
  double currentProgress = 0.0;

  // Track all user answers
  List<String> userAnswers = [];
  bool _showingResults = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _resultData;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize the answers list with nulls
    userAnswers = List.filled(widget.questions?.length ?? 0, '');

    _startProgressAnimation();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  void _startProgressAnimation() {
    final target = (currentQuestionIndex + 1) / widget.questions!.length;
    progressAnimation = Tween<double>(
      begin: currentProgress,
      end: target,
    ).animate(CurvedAnimation(
      parent: progressController,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {
          currentProgress = progressAnimation.value;
        });
      });

    progressController.forward(from: 0.0);
  }

  void _nextQuestion() {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une réponse avant de continuer',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Save the selected answer
    userAnswers[currentQuestionIndex] = selectedAnswer!;

    if (currentQuestionIndex < widget.questions!.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
      _startProgressAnimation();
    } else {
      // All questions answered, submit answers
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final questionService =
          Provider.of<QuestionService>(context, listen: false);
      final results =
          await questionService.submitAnswers(widget.currentLevel, userAnswers);

      setState(() {
        _resultData = results;
        _showingResults = true;
        _isSubmitting = false;
      });

      // If all answers are correct, proceed to next level
      if (results['levelCompleted'] == true) {
        // Wait a moment to show results before moving to next level
        Future.delayed(const Duration(seconds: 2), () {
          debugPrint('All answers correct! Moving to next level.');
          widget.onComplete();
          widget.game.overlays.remove('QuestionOverlay');
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildResultsScreen() {
    if (_resultData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final score = _resultData!['score'] ?? 0;
    final correctAnswers = _resultData!['correctAnswers'] ?? 0;
    final totalQuestions =
        _resultData!['totalQuestions'] ?? widget.questions!.length;
    final passed = _resultData!['passed'] == true;
    final answerResults = _resultData!['answerResults'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            passed ? 'Félicitations !' : 'Résultats',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: passed ? Colors.green : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: $score%',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$correctAnswers/$totalQuestions réponses correctes',
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          if (passed)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            )
          else
            const Icon(
              Icons.info,
              color: Colors.orange,
              size: 64,
            ),
          const SizedBox(height: 16),
          Text(
            passed
                ? 'Vous avez réussi ce niveau !'
                : 'Vous devez répondre correctement à toutes les questions pour passer au niveau suivant.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!passed)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex = 0;
                      selectedAnswer = null;
                      userAnswers =
                          List.filled(widget.questions?.length ?? 0, '');
                      _showingResults = false;
                      _resultData = null;
                    });
                    _startProgressAnimation();
                  },
                  child: Text(
                    'Réessayer',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? Colors.green : Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  widget.game.overlays.remove('QuestionOverlay');
                },
                child: Text(
                  'Retour à la carte',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return Material(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showingResults) {
      return Material(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: _buildResultsScreen(),
        ),
      );
    }

    final question = widget.questions![currentQuestionIndex];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              debugPrint(
                                  'Back button pressed. Returning to map page...');
                              widget.game.overlays.remove(
                                  'QuestionOverlay'); // Remove the overlay
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Niveau ${widget.currentLevel} - Question ${currentQuestionIndex + 1}/${widget.questions!.length}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 48.w),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 25),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedBuilder(
                            animation: progressAnimation,
                            builder: (context, _) {
                              return LinearProgressIndicator(
                                minHeight: 20,
                                value: currentProgress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFFF5F5F5)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 140.h),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          question.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: question.options.length,
                            itemBuilder: (context, index) {
                              final option = question.options[index];
                              final isSelected = selectedAnswer == option;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswer = option;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color.fromARGB(
                                            255, 205, 237, 174)
                                        : const Color(0xFFF5F5F5),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color.fromARGB(
                                              255, 180, 220, 143)
                                          : const Color(0xFFE0E0E0),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? const Color(0xFF66B51B)
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle,
                                            color: Color(0xFF66B51B), size: 24),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66B51B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _nextQuestion,
                            child: Text(
                              currentQuestionIndex ==
                                      widget.questions!.length - 1
                                  ? 'Terminer' // Change button text to "Terminer" on the last question
                                  : 'Suivant',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
