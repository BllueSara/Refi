import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  BookDetailsCubit({
    required int currentPage,
    required int totalPages,
    BookStatus status = BookStatus.reading,
  }) : super(
         BookDetailsState(
           currentPage: currentPage,
           totalPages: totalPages,
           status: status,
         ),
       );

  void updateProgress(int newPage) {
    if (newPage < 0 || newPage > state.totalPages) return;

    // Check if completed
    BookStatus newStatus = state.status;
    if (newPage == state.totalPages) {
      newStatus = BookStatus.completed;
    } else if (newPage > 0 && state.status == BookStatus.wishlist) {
      newStatus = BookStatus.reading;
    }

    emit(state.copyWith(currentPage: newPage, status: newStatus));
  }

  void changeStatus(BookStatus status) {
    emit(state.copyWith(status: status));
  }

  // Mock adding a quote
  void addQuote(String quote) {
    final updatedQuotes = List<String>.from(state.quotes)..add(quote);
    emit(state.copyWith(quotes: updatedQuotes));
  }
}
