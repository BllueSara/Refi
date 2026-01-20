import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote_entity.dart';
import '../repositories/quote_repository.dart';

class GetUserQuotesUseCase {
  final QuoteRepository repository;

  GetUserQuotesUseCase(this.repository);

  Future<Either<Failure, List<QuoteEntity>>> call() async {
    return await repository.getUserQuotes();
  }
}
