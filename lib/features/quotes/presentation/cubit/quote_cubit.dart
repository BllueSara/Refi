import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/save_quote_usecase.dart';
import '../../domain/usecases/get_user_quotes_usecase.dart';
import '../../domain/usecases/get_book_quotes_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../../../features/scanner/domain/usecases/extract_text_from_image_usecase.dart';

// States
abstract class QuoteState extends Equatable {
  const QuoteState();
  @override
  List<Object> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuoteLoading extends QuoteState {}

class QuoteSaving extends QuoteState {}

class QuoteSaved extends QuoteState {}

class QuotesLoaded extends QuoteState {
  final List<QuoteEntity> quotes;
  const QuotesLoaded(this.quotes);
  @override
  List<Object> get props => [quotes];
}

class QuoteScanning extends QuoteState {}

class QuoteScanned extends QuoteState {
  final String text;
  const QuoteScanned(this.text);
  @override
  List<Object> get props => [text];
}

class QuoteError extends QuoteState {
  final String message;
  const QuoteError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class QuoteCubit extends Cubit<QuoteState> {
  final SaveQuoteUseCase saveQuoteUseCase;
  final GetUserQuotesUseCase getUserQuotesUseCase;
  final GetBookQuotesUseCase getBookQuotesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final ExtractTextFromImageUseCase extractTextFromImageUseCase;

  QuoteCubit({
    required this.saveQuoteUseCase,
    required this.getUserQuotesUseCase,
    required this.getBookQuotesUseCase,
    required this.toggleFavoriteUseCase,
    required this.extractTextFromImageUseCase,
  }) : super(QuoteInitial());

  Future<void> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
    bool isFavorite = false,
  }) async {
    emit(QuoteSaving());

    final result = await saveQuoteUseCase(
      text: text,
      bookId: bookId,
      feeling: feeling,
      notes: notes,
      isFavorite: isFavorite,
    );

    result.fold(
      (failure) => emit(QuoteError(failure.message)),
      (_) => emit(QuoteSaved()),
    );
  }

  Future<void> loadUserQuotes() async {
    emit(QuoteLoading());

    final result = await getUserQuotesUseCase();

    result.fold(
      (failure) => emit(QuoteError(failure.message)),
      (quotes) {
        // Smart Sorting: Latest Added First
        final sortedQuotes = List<QuoteEntity>.from(quotes)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(QuotesLoaded(sortedQuotes));
      },
    );
  }

  Future<void> loadBookQuotes(String bookId) async {
    emit(QuoteLoading());

    final result = await getBookQuotesUseCase(bookId);

    result.fold(
      (failure) => emit(QuoteError(failure.message)),
      (quotes) => emit(QuotesLoaded(quotes)),
    );
  }

  Future<void> toggleFavorite(QuoteEntity quote) async {
    // Optimistic Update
    if (state is QuotesLoaded) {
      final currentQuotes = (state as QuotesLoaded).quotes;
      final updatedQuotes = currentQuotes.map((q) {
        if (q.id == quote.id) {
          return QuoteEntity(
            id: q.id,
            text: q.text,
            bookId: q.bookId,
            bookTitle: q.bookTitle,
            bookAuthor: q.bookAuthor,
            bookCoverUrl: q.bookCoverUrl,
            feeling: q.feeling,
            notes: q.notes,
            isFavorite: !q.isFavorite,
            createdAt: q.createdAt,
          );
        }
        return q;
      }).toList();
      emit(QuotesLoaded(updatedQuotes));
    }

    // Call Repository
    final result = await toggleFavoriteUseCase(
      quoteId: quote.id,
      isFavorite: !quote.isFavorite,
    );

    result.fold(
      (failure) {
        // Revert or Reload
        loadUserQuotes();
      },
      (_) => null,
    );
  }

  Future<void> scanImage(String imagePath) async {
    emit(QuoteScanning());
    final result = await extractTextFromImageUseCase(imagePath);
    result.fold(
      (failure) => emit(QuoteError(failure.message)),
      (text) => emit(QuoteScanned(text)),
    );
  }
}
