abstract class AuthEvent {}

class ToggleAuthMode extends AuthEvent {}

class SubmitAuth extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  SubmitAuth({required this.email, required this.password, this.name});
}

class LogoutRequested extends AuthEvent {}
