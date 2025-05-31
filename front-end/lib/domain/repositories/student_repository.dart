import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents();
  Future<Student> getStudentById(String id);
  Future<Student> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<Student> createStudent(Student student);
  Future<Map<String, dynamic>> getStudentProgress(String studentId);
  Future<void> updateStudentProgress(
      String studentId, Map<String, dynamic> progress);
}
