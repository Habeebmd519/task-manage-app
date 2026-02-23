import 'app_exception.dart';

class NetworkException extends AppException {
  NetworkException([String message = "No internet connection"])
    : super(message);
}
