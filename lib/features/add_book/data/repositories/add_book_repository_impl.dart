import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/add_book_repository.dart';

class AddBookRepositoryImpl implements AddBookRepository {
  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    // Mock Implementation simulating Google Books API
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulating network delay

    if (query.toLowerCase().contains("fan") || query.contains("فن")) {
      return const [
        BookEntity(
          id: "1",
          title: "فن اللامبالاة",
          author: "مارك مانسون",
          rating: 4.8,
          coverUrl: null, // Placeholder in UI
        ),
        BookEntity(
          id: "2",
          title: "خراب: كتاب عن الأمل",
          author: "مارك مانسون",
          rating: 4.5,
          coverUrl: null,
        ),
        BookEntity(
          id: "3",
          title: "فن التواصل مع الآخرين",
          author: "ديل كارنيجي",
          rating: 4.2,
          coverUrl: null,
        ),
        BookEntity(
          id: "4",
          title: "قوة الآن",
          author: "إيكهارت تول",
          rating: 4.9,
          coverUrl: null,
        ),
      ];
    } else if (query.isEmpty) {
      return [];
    } else {
      return []; // Empty result test case
    }
  }

  @override
  Future<void> addBook(BookEntity book) async {
    // Mock Supabase Insertion
    await Future.delayed(const Duration(seconds: 1));
  }
}
