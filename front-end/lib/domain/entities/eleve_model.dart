class Eleve {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;

  Eleve({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['_id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      age: json['age'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'age': age,
    };
  }
}
