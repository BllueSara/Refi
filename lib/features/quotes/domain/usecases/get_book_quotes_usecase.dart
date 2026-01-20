import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote_entity.dart';
import '../repositories/quote_repository.dart';

class GetBookQuotesUseCase {
  final QuoteRepository repository;

  GetBookQuotesUseCase(this.repository);

  Future<Either<Failure, List<QuoteEntity>>> call(String bookId) async {
    return await repository.getBookQuotes(bookId);
  }
}
