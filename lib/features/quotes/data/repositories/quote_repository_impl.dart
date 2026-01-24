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
    bool isFavorite = false,
  }) async {
    try {
      await remoteDataSource.saveQuote(
        text: text,
        bookId: bookId,
        feeling: feeling,
        notes: notes,
        isFavorite: isFavorite,
      );
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('PostgresException')) {
        // Swallow PG exceptions to avoid showing technical errors to user.
        // Log it internally ideally.
        // Returning Right(null) might be misleading if it actually failed,
        // but prevents user error. Let's return a friendly error instead OR
        // checks specifically for foreign key violation if that's the issue.
        // User said "Ensure... user never sees technical error text again".
        return const Left(
            ServerFailure('حدث خطأ أثناء حفظ الاقتباس، يرجى المحاولة لاحقاً'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getUserQuotes() async {
    try {
      final quotes = await remoteDataSource.getUserQuotes();
      return Right(quotes);
    } catch (e) {
      if (e.toString().contains('PostgresException')) {
        return const Left(ServerFailure('تعذر تحميل الاقتباسات حالياً'));
      }
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
      if (e.toString().contains('PostgresException')) {
        return const Left(ServerFailure('تعذر تحميل اقتباسات هذا الكتاب'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite({
    required String quoteId,
    required bool isFavorite,
  }) async {
    try {
      await remoteDataSource.toggleFavorite(
          quoteId: quoteId, isFavorite: isFavorite);
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('PostgresException')) {
        return const Left(ServerFailure('تعذر تحديث المفضلة حالياً'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
