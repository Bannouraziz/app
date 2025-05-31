import '../domain/entities/question_model.dart';

class MockData {
  static final List<Question> questions = [
    Question(
      id: '1',
      text: 'Quelle est la capitale de la France ?',
      options: ['Paris', 'Lyon', 'Marseille', 'Bordeaux'],
      correctAnswer: 'Paris',
      level: 1,
      explanation: 'Paris est la capitale de la France depuis le Moyen Âge.',
    ),
    Question(
      id: '2',
      text: 'Combien de côtés a un hexagone ?',
      options: ['4', '5', '6', '8'],
      correctAnswer: '6',
      level: 1,
      explanation: 'Un hexagone a 6 côtés égaux.',
    ),
    Question(
      id: '3',
      text: 'Quel est le plus grand océan du monde ?',
      options: ['Atlantique', 'Indien', 'Arctique', 'Pacifique'],
      correctAnswer: 'Pacifique',
      level: 2,
      explanation: 'L\'océan Pacifique est le plus grand et le plus profond des océans.',
    ),
    Question(
      id: '4',
      text: 'Qui a peint la Joconde ?',
      options: ['Van Gogh', 'Michel-Ange', 'Léonard de Vinci', 'Picasso'],
      correctAnswer: 'Léonard de Vinci',
      level: 2,
      explanation: 'La Joconde a été peinte par Léonard de Vinci au début du XVIe siècle.',
    ),
    Question(
      id: '5',
      text: 'Quelle est la formule chimique de l\'eau ?',
      options: ['CO2', 'H2O', 'O2', 'H2SO4'],
      correctAnswer: 'H2O',
      level: 3,
      explanation: 'L\'eau est composée de deux atomes d\'hydrogène (H2) et d\'un atome d\'oxygène (O).',
    ),
      Question(
      id: '6',
      text: 'Quelle est la formule chimique de l\'eau ?',
      options: ['CO2', 'H2O', 'O2', 'H2SO4'],
      correctAnswer: 'H2O',
      level: 3,
      explanation: 'L\'eau est composée de deux atomes d\'hydrogène (H2) et d\'un atome d\'oxygène (O).',
    ),
  ];

  static final Map<String, dynamic> mockUser = {
    'id': '1',
    'fullName': 'John Doe',
    'email': 'john@example.com',
    'level': 1,
    'progress': 0.0,
    'achievements': [],
  };

  static final Map<String, dynamic> mockProgress = {
    'completedLevels': [1],
    'currentLevel': 1,
    'totalScore': 100,
    'achievements': [
      {
        'id': '1',
        'title': 'Premier pas',
        'description': 'Compléter le premier niveau',
        'unlockedAt': '2024-03-20T10:00:00Z',
      }
    ],
  };
}
