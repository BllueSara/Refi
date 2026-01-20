import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/search_books_usecase.dart';

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<BookEntity> books;
  const SearchSuccess(this.books);
  @override
  List<Object> get props => [books];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class SearchCubit extends Cubit<SearchState> {
  final SearchBooksUseCase searchBooksUseCase;

  SearchCubit({required this.searchBooksUseCase}) : super(SearchInitial());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    final result = await searchBooksUseCase(query);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (books) => emit(SearchSuccess(books)),
    );
  }
}
