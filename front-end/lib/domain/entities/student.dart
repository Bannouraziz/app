class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String grade;
  final int age;
  final Map<String, dynamic> progress;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.grade,
    required this.age,
    required this.progress,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      grade: json['grade'] as String,
      age: json['age'] as int,
      progress: json['progress'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'grade': grade,
      'age': age,
      'progress': progress,
    };
  }
}
