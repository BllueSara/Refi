import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/book_repository.dart';

class DeleteBookUseCase {
  final BookRepository repository;

  DeleteBookUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookId) async {
    return await repository.deleteBook(bookId);
  }
}
