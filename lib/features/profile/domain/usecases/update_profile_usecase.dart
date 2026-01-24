import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    String? fullName,
    int? annualGoal,
    String? avatarUrl,
  }) async {
    return await repository.updateProfile(
      userId: userId,
      fullName: fullName,
      annualGoal: annualGoal,
      avatarUrl: avatarUrl,
    );
  }
}
