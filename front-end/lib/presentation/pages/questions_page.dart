import 'package:flutter/material.dart';
import '../../services/question_service.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionsScreen extends StatefulWidget {
  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late QuestionService _questionService;
  List<Map<String, dynamic>> _questions = [];
  List<String> _answers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _questionService = QuestionService(
      apiService: ApiService(baseUrl: 'http://localhost:3000/api'),
      prefs: prefs,
    );
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final niveau = ModalRoute.of(context)!.settings.arguments as int;
      final questions = await _questionService.getQuestionsForLevel(niveau);
      setState(() {
        _questions = questions;
        _answers = List.filled(questions.length, '');
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des questions')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAnswers() async {
    if (_answers.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez répondre à toutes les questions')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final niveau = ModalRoute.of(context)!.settings.arguments as int;
      final result = await _questionService.submitAnswers(niveau, _answers);

      if (result['levelCompleted']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Félicitations ! Niveau complété !')),
        );
        Navigator.pop(
            context, true); // Return true to indicate level completion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Certaines réponses sont incorrectes. Essayez encore !')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission des réponses')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Questions')),
        body: Center(child: Text('Aucune question disponible')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...currentQuestion['propositions'].map<Widget>((proposition) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text(proposition),
                  value: proposition,
                  groupValue: _answers[_currentQuestionIndex],
                  onChanged: (value) {
                    setState(() {
                      _answers[_currentQuestionIndex] = value!;
                    });
                  },
                ),
              );
            }).toList(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    child: Text('Précédent'),
                  ),
                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    },
                    child: Text('Suivant'),
                  ),
                if (_currentQuestionIndex == _questions.length - 1)
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAnswers,
                    child: _isSubmitting
                        ? CircularProgressIndicator()
                        : Text('Soumettre'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
