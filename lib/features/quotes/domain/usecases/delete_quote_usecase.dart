import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/quote_repository.dart';

class DeleteQuoteUseCase {
  final QuoteRepository repository;

  DeleteQuoteUseCase(this.repository);

  Future<Either<Failure, void>> call(String quoteId) async {
    return await repository.deleteQuote(quoteId);
  }
}
