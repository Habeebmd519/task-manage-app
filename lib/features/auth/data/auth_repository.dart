import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<void> login({required String email, required String password}) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _authService.signUp(email: email, password: password, name: name);
  }
}
