import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/data/auth_service.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthState()) {
    on<ToggleAuthMode>((event, emit) {
      emit(state.copyWith(isLogin: !state.isLogin));
    });

    on<SubmitAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));

      try {
        if (state.isLogin) {
          await authService.login(email: event.email, password: event.password);
        } else {
          await authService.signUp(
            email: event.email,
            password: event.password,
            name: event.name ?? "",
          );
        }

        emit(state.copyWith(status: AuthStatus.success));
      } catch (e) {
        emit(
          state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
        );
      }
    });
    on<LogoutRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await authService.signOut();
        // Reset state to initial on logout
        emit(AuthState(status: AuthStatus.initial));
      } catch (e) {
        emit(
          state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
        );
      }
    });
  }
}
