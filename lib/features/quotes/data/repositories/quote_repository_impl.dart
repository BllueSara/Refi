import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_remote_data_source.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteDataSource remoteDataSource;

  QuoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
  }) async {
    try {
      await remoteDataSource.saveQuote(
        text: text,
        bookId: bookId,
        feeling: feeling,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getUserQuotes() async {
    try {
      final quotes = await remoteDataSource.getUserQuotes();
      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getBookQuotes(
    String bookId,
  ) async {
    try {
      final quotes = await remoteDataSource.getBookQuotes(bookId);
      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
