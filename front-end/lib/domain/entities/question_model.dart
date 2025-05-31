class Question {
  final String id;
  final String text;
  final List<String> options;
  final String correctAnswer;
  final int level;
  final String? explanation;
  final Map<String, dynamic>? metadata;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.level,
    this.explanation,
    this.metadata,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      level: json['level'] as int,
      explanation: json['explanation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'level': level,
      'explanation': explanation,
      'metadata': metadata,
    };
  }
}
