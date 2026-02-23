import 'app_exception.dart';

class AuthException extends AppException {
  AuthException([String message = "Authentication failed"]) : super(message);
}
