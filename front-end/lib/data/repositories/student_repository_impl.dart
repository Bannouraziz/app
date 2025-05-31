import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_service.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentService _studentService;

  StudentRepositoryImpl(this._studentService);

  @override
  Future<List<Student>> getStudents() async {
    try {
      final response = await _studentService.getStudents();
      return response.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }

  @override
  Future<Student> getStudentById(String id) async {
    try {
      final response = await _studentService.getStudentById(id);
      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  @override
  Future<Student> updateStudent(Student student) async {
    try {
      final response = await _studentService.updateStudent(student.toJson());
      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      await _studentService.deleteStudent(id);
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  @override
  Future<Student> createStudent(Student student) async {
    try {
      final response = await _studentService.createStudent(student.toJson());
      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    try {
      return await _studentService.getStudentProgress(studentId);
    } catch (e) {
      throw Exception('Failed to get student progress: $e');
    }
  }

  @override
  Future<void> updateStudentProgress(
      String studentId, Map<String, dynamic> progress) async {
    try {
      await _studentService.updateStudentProgress(studentId, progress);
    } catch (e) {
      throw Exception('Failed to update student progress: $e');
    }
  }
}
