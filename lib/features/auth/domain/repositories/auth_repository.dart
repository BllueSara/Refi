import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
}
