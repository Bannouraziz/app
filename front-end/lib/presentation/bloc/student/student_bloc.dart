import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/repositories/student_repository.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _studentRepository;

  StudentBloc(this._studentRepository) : super(StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentById>(_onLoadStudentById);
    on<CreateStudent>(_onCreateStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<UpdateStudentProgress>(_onUpdateStudentProgress);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final students = await _studentRepository.getStudents();
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentById(
    LoadStudentById event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final student = await _studentRepository.getStudentById(event.id);
      emit(StudentLoaded(student));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onCreateStudent(
    CreateStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final student = await _studentRepository.createStudent(
        Student.fromJson(event.student),
      );
      emit(StudentLoaded(student));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final student = await _studentRepository.updateStudent(
        Student.fromJson(event.student),
      );
      emit(StudentLoaded(student));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await _studentRepository.deleteStudent(event.id);
      emit(StudentInitial());
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateStudentProgress(
    UpdateStudentProgress event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await _studentRepository.updateStudentProgress(
        event.studentId,
        event.progress,
      );
      final progress =
          await _studentRepository.getStudentProgress(event.studentId);
      emit(StudentProgressUpdated(progress));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
