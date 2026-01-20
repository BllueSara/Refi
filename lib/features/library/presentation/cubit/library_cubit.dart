import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/add_book_to_library_usecase.dart';
import '../../domain/usecases/fetch_user_library_usecase.dart';

// States
abstract class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryEmpty extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<BookEntity> books;
  const LibraryLoaded(this.books);
  @override
  List<Object> get props => [books];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class LibraryCubit extends Cubit<LibraryState> {
  final FetchUserLibraryUseCase fetchUserLibraryUseCase;
  final AddBookToLibraryUseCase addBookToLibraryUseCase;

  // Note: Search might be handled by a separate Cubit or here if we want to mix.
  // For Clean Arch compatibility with "SearchScreen" needing to "add" books that reflected in Library,
  // keeping them tied via injection or listeners is key.
  // I will create a separate SearchCubit for the Search UI to avoid polluting LibraryState with SearchResults.

  LibraryCubit({
    required this.fetchUserLibraryUseCase,
    required this.addBookToLibraryUseCase,
  }) : super(LibraryInitial());

  Future<void> loadLibrary() async {
    emit(LibraryLoading());
    final result = await fetchUserLibraryUseCase();
    result.fold(
      (failure) {
        emit(LibraryError(failure.message));
      },
      (books) {
        if (books.isEmpty) {
          emit(LibraryEmpty());
        } else {
          emit(LibraryLoaded(books));
        }
      },
    );
  }

  Future<void> addBook(BookEntity book) async {
    // We don't emit loading here necessarily to avoid full screen spinner on main user library if not visible,
    // but better to optimistic update or simple reload.
    // For now, simple reload.
    // emit(LibraryLoading()); // Maybe don't block?

    final result = await addBookToLibraryUseCase(book);
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (_) => loadLibrary(), // Refresh list
    );
  }
}
