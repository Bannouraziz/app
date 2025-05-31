import '../../core/config/app_config.dart';
import '../../core/network/api_service.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  Future<List<Map<String, dynamic>>> getStudents() async {
    final response = await _apiService.get(AppConfig.studentsEndpoint);
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<Map<String, dynamic>> getStudentById(String id) async {
    final response = await _apiService.get('${AppConfig.studentsEndpoint}/$id');
    return response['data'];
  }

  Future<Map<String, dynamic>> updateStudent(
      Map<String, dynamic> student) async {
    final response = await _apiService.put(
      '${AppConfig.studentsEndpoint}/${student['id']}',
      student,
    );
    return response['data'];
  }

  Future<void> deleteStudent(String id) async {
    await _apiService.delete('${AppConfig.studentsEndpoint}/$id');
  }

  Future<Map<String, dynamic>> createStudent(
      Map<String, dynamic> student) async {
    final response = await _apiService.post(
      AppConfig.studentsEndpoint,
      student,
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    final response = await _apiService.get(
      '${AppConfig.studentsEndpoint}/$studentId/progress',
    );
    return response['data'];
  }

  Future<void> updateStudentProgress(
    String studentId,
    Map<String, dynamic> progress,
  ) async {
    await _apiService.put(
      '${AppConfig.studentsEndpoint}/$studentId/progress',
      progress,
    );
  }
}
