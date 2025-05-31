abstract class StudentEvent {}

class LoadStudents extends StudentEvent {}

class LoadStudentById extends StudentEvent {
  final String id;

  LoadStudentById(this.id);
}

class CreateStudent extends StudentEvent {
  final Map<String, dynamic> student;

  CreateStudent(this.student);
}

class UpdateStudent extends StudentEvent {
  final Map<String, dynamic> student;

  UpdateStudent(this.student);
}

class DeleteStudent extends StudentEvent {
  final String id;

  DeleteStudent(this.id);
}

class UpdateStudentProgress extends StudentEvent {
  final String studentId;
  final Map<String, dynamic> progress;

  UpdateStudentProgress(this.studentId, this.progress);
}
