abstract class Failure {
  final String message;
  final int? statusCode;

  Failure({
    required this.message,
    this.statusCode,
  });
}

class ApiFailure extends Failure {
  ApiFailure({
    required String message,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
  }) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({
    required String message,
  }) : super(message: message);
}

class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
  }) : super(message: message);
}
