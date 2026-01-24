import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/quote_repository.dart';

class ToggleFavoriteUseCase {
  final QuoteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String quoteId,
    required bool isFavorite,
  }) async {
    return await repository.toggleFavorite(
        quoteId: quoteId, isFavorite: isFavorite);
  }
}
