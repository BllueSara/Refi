import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book_entity.dart';

abstract class BookRepository {
  Future<Either<Failure, List<BookEntity>>> searchBooks(String query);
  Future<Either<Failure, void>> addBookToLibrary(BookEntity book);
  Future<Either<Failure, void>> updateBook(BookEntity book);
  Future<Either<Failure, List<BookEntity>>> fetchUserLibrary();
}
