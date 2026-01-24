import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BookEntity>>> searchBooks(String query) async {
    try {
      final books = await remoteDataSource.searchBooks(query);
      return Right(books);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBookToLibrary(BookEntity book) async {
    try {
      // Convert Entity to Model to use toSupabase
      final bookModel = BookModel(
        id: book.id,
        title: book.title,
        authors: book.authors,
        imageUrl: book.imageUrl,
        rating: book.rating,
        description: book.description,
        publishedDate: book.publishedDate,
        pageCount: book.pageCount,
        status: book.status,
        currentPage: book.currentPage,
        categories: book.categories,
        googleBookId: book.googleBookId,
        source: book.source,
      );
      await remoteDataSource.addBookToLibrary(bookModel);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(BookEntity book) async {
    return addBookToLibrary(
      book,
    ); // Re-use upsert logic for now, it's efficient enough for this scale
  }

  @override
  Future<Either<Failure, List<BookEntity>>> fetchUserLibrary() async {
    try {
      final books = await remoteDataSource.fetchUserLibrary();
      return Right(books);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String bookId) async {
    try {
      await remoteDataSource.deleteBook(bookId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
