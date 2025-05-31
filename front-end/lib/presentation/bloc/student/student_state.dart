import '../../../domain/entities/student.dart';

abstract class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentsLoaded extends StudentState {
  final List<Student> students;

  StudentsLoaded(this.students);
}

class StudentLoaded extends StudentState {
  final Student student;

  StudentLoaded(this.student);
}

class StudentError extends StudentState {
  final String message;

  StudentError(this.message);
}

class StudentProgressUpdated extends StudentState {
  final Map<String, dynamic> progress;

  StudentProgressUpdated(this.progress);
}
