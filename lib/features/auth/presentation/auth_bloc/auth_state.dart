enum AuthStatus { initial, loading, success, error }

class AuthState {
  final bool isLogin;
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    this.isLogin = true,
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLogin,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
