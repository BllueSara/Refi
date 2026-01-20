import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class AddBookToLibraryUseCase {
  final BookRepository repository;

  AddBookToLibraryUseCase(this.repository);

  Future<Either<Failure, void>> call(BookEntity book) async {
    return await repository.addBookToLibrary(book);
  }
}
