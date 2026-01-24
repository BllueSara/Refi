import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote_entity.dart';

abstract class QuoteRepository {
  Future<Either<Failure, void>> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
    bool isFavorite = false,
  });

  Future<Either<Failure, List<QuoteEntity>>> getUserQuotes();

  Future<Either<Failure, List<QuoteEntity>>> getBookQuotes(String bookId);

  Future<Either<Failure, void>> toggleFavorite({
    required String quoteId,
    required bool isFavorite,
  });
}
