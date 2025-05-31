class Reponse {
  final String id;
  final String questionId;
  final String eleveId;
  final String reponse;
  final bool isCorrect;
  final DateTime createdAt;

  Reponse({
    required this.id,
    required this.questionId,
    required this.eleveId,
    required this.reponse,
    required this.isCorrect,
    required this.createdAt,
  });

  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      id: json['_id'],
      questionId: json['questionId'],
      eleveId: json['eleveId'],
      reponse: json['reponse'],
      isCorrect: json['isCorrect'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'reponse': reponse,
    };
  }
}
