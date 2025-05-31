class Progression {
  final String id;
  final String eleveId;
  final int niveau;
  final int points;
  final List<String> badges;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Progression({
    required this.id,
    required this.eleveId,
    required this.niveau,
    required this.points,
    required this.badges,
    required this.lastActivity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Progression.fromJson(Map<String, dynamic> json) {
    return Progression(
      id: json['_id'],
      eleveId: json['eleveId'],
      niveau: json['niveau'],
      points: json['points'],
      badges: List<String>.from(json['badges']),
      lastActivity: DateTime.parse(json['lastActivity']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'niveau': niveau,
      'points': points,
      'badges': badges,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}
