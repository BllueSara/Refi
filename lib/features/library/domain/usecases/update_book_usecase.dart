import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class UpdateBookUseCase {
  final BookRepository repository;

  UpdateBookUseCase(this.repository);

  Future<Either<Failure, void>> call(BookEntity book) async {
    return await repository.updateBook(book);
  }
}
