import '../entities/book_entity.dart';

abstract class AddBookRepository {
  Future<List<BookEntity>> searchBooks(String query);
  Future<void> addBook(BookEntity book);
}
