import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/add_book_repository.dart';

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<BookEntity> books;

  const SearchLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class SearchCubit extends Cubit<SearchState> {
  final AddBookRepository repository;

  SearchCubit(this.repository) : super(SearchInitial());

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await repository.searchBooks(query);
      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(results));
      }
    } catch (e) {
      emit(const SearchError("Failed to fetch books"));
    }
  }
}
