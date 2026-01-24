import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/quote_repository.dart';

class SaveQuoteUseCase {
  final QuoteRepository repository;

  SaveQuoteUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
    bool isFavorite = false,
  }) async {
    return await repository.saveQuote(
      text: text,
      bookId: bookId,
      feeling: feeling,
      notes: notes,
      isFavorite: isFavorite,
    );
  }
}
