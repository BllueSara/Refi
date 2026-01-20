import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class SearchBooksUseCase {
  final BookRepository repository;

  SearchBooksUseCase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call(String query) async {
    return await repository.searchBooks(query);
  }
}
