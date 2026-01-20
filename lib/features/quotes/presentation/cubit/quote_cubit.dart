import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/save_quote_usecase.dart';
import '../../domain/usecases/get_user_quotes_usecase.dart';
import '../../domain/usecases/get_book_quotes_usecase.dart';

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

  QuoteCubit({
    required this.saveQuoteUseCase,
    required this.getUserQuotesUseCase,
    required this.getBookQuotesUseCase,
  }) : super(QuoteInitial());

  Future<void> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
  }) async {
    emit(QuoteSaving());

    final result = await saveQuoteUseCase(
      text: text,
      bookId: bookId,
      feeling: feeling,
      notes: notes,
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
      (quotes) => emit(QuotesLoaded(quotes)),
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
}
