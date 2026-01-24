import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/signin_with_google_usecase.dart';

import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFirstTime extends AuthState {}

class AuthPasswordResetSent extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final SharedPreferences sharedPreferences;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.signInWithGoogleUseCase,
    required this.resetPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.sharedPreferences,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        final seen = sharedPreferences.getBool('onboarding_seen') ?? false;
        if (seen) {
          emit(AuthUnauthenticated());
        } else {
          emit(AuthFirstTime());
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> setOnboardingSeen() async {
    await sharedPreferences.setBool('onboarding_seen', true);
    emit(AuthUnauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await signUpUseCase(email, password, name);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await signOutUseCase();
    // Always navigate to login, even if server error occurs
    emit(AuthUnauthenticated());
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await signInWithGoogleUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    emit(AuthLoading());
    final result = await updatePasswordUseCase(newPassword);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent()), // Reuse this state for success
    );
  }
}
