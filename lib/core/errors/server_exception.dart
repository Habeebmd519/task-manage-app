import 'app_exception.dart';

class ServerException extends AppException {
  ServerException([String message = "Server error occurred", int? code])
    : super(message, code: code);
}
