import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
