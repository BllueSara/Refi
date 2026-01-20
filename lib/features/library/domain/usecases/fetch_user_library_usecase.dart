import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class FetchUserLibraryUseCase {
  final BookRepository repository;

  FetchUserLibraryUseCase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call() async {
    return await repository.fetchUserLibrary();
  }
}
