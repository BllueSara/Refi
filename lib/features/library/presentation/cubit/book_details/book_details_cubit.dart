import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/book_entity.dart';
import '../../../domain/usecases/update_book_usecase.dart';
import '../../../../quotes/domain/usecases/get_book_quotes_usecase.dart';
import 'book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  final BookEntity book;
  final UpdateBookUseCase updateBookUseCase;
  final GetBookQuotesUseCase getBookQuotesUseCase;

  BookDetailsCubit({
    required this.book,
    required this.updateBookUseCase,
    required this.getBookQuotesUseCase,
  }) : super(
          BookDetailsState(
            currentPage: book.currentPage,
            totalPages: book.pageCount ?? 0,
            status: book.status,
          ),
        ) {
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final result = await getBookQuotesUseCase(book.id);
    result.fold(
      (failure) => null, // Just ignore error for now or handle it
      (quotes) => emit(state.copyWith(quotes: quotes)),
    );
  }

  Future<void> updateProgress(int newPage) async {
    if (newPage < 0 || newPage > state.totalPages) return;

    // Check if completed
    BookStatus newStatus = state.status;
    if (newPage == state.totalPages) {
      newStatus = BookStatus.completed;
    } else if (newPage > 0 && state.status == BookStatus.wishlist) {
      newStatus = BookStatus.reading;
    }

    emit(state.copyWith(currentPage: newPage, status: newStatus));

    // Save to backend
    await _saveChanges();
  }

  Future<void> changeStatus(BookStatus status) async {
    emit(state.copyWith(status: status));
    await _saveChanges();
  }

  Future<void> _saveChanges() async {
    // Reconstruct updated book
    final updatedBook = BookEntity(
      id: book.id,
      title: book.title,
      authors: book.authors,
      imageUrl: book.imageUrl,
      rating: book.rating,
      description: book.description,
      publishedDate: book.publishedDate,
      pageCount: book.pageCount,
      // Updated fields
      status: state.status,
      currentPage: state.currentPage,
      categories: book.categories,
    );

    final result = await updateBookUseCase(updatedBook);
    result.fold(
      (failure) {
        // Optionally emit error state or revert
        // print("Update failed: ${failure.message}");
      },
      (success) {
        // Success
      },
    );
  }
}
