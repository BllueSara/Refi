import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/signin_with_google_usecase.dart';
import '../../domain/usecases/signin_with_apple_usecase.dart';

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
  final SignInWithAppleUseCase signInWithAppleUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
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

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await signInWithGoogleUseCase();
    result.fold((failure) {
      if (failure.message == "Redirecting...") {
        // Do nothing/Stay in loading or emit initial
        // Ideally we wait for onAuthStateChange
        emit(AuthInitial());
      } else {
        emit(AuthError(failure.message));
      }
    }, (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> signInWithApple() async {
    emit(AuthLoading());
    final result = await signInWithAppleUseCase();
    result.fold((failure) {
      if (failure.message == "Redirecting...") {
        emit(AuthInitial());
      } else {
        emit(AuthError(failure.message));
      }
    }, (user) => emit(AuthAuthenticated(user)));
  }
}
