import 'app_exception.dart';

class CacheException extends AppException {
  CacheException([String message = "Cache error occurred"]) : super(message);
}
