import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/add_book_to_library_usecase.dart';
import '../../domain/usecases/fetch_user_library_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';

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
  final DeleteBookUseCase deleteBookUseCase;
  final UpdateBookUseCase updateBookUseCase;

  // Note: Search might be handled by a separate Cubit or here if we want to mix.
  // For Clean Arch compatibility with "SearchScreen" needing to "add" books that reflected in Library,
  // keeping them tied via injection or listeners is key.
  // I will create a separate SearchCubit for the Search UI to avoid polluting LibraryState with SearchResults.

  LibraryCubit({
    required this.fetchUserLibraryUseCase,
    required this.addBookToLibraryUseCase,
    required this.deleteBookUseCase,
    required this.updateBookUseCase,
  }) : super(LibraryInitial());

  Future<void> loadLibrary({bool forceRefresh = false}) async {
    if (isClosed) return;
    
    // Always fetch fresh data when forceRefresh is true
    if (forceRefresh) {
      // Don't show loading if we already have data (better UX)
      // Just refresh in background
    } else {
      // Only skip if we already have loaded data
      if (state is LibraryLoaded) {
        return; // Data exists, do nothing
      }
    }

    // Initial load - show loading
    if (state is LibraryInitial) {
      if (!isClosed) emit(LibraryLoading());
    }

    // Fetch data
    final result = await fetchUserLibraryUseCase();
    
    if (isClosed) return;
    
    result.fold(
      (failure) {
        // If we have data, keep it and maybe show error via snackbar (not handled here completely)
        // For now, if no data, show Error.
        if (state is! LibraryLoaded) {
          if (!isClosed) emit(LibraryError(failure.message));
        }
      },
      (books) {
        if (isClosed) return;
        
        if (books.isEmpty) {
          if (!isClosed) emit(LibraryEmpty());
        } else {
          // Always emit new state to trigger rebuild
          if (!isClosed) emit(LibraryLoaded(books));
        }
      },
    );
  }

  Future<void> addBook(BookEntity book) async {
    if (isClosed) return;
    
    // Optimistic Update: Add book immediately to UI
    if (state is LibraryLoaded) {
      final currentBooks = (state as LibraryLoaded).books;
      final updatedBooks = [book, ...currentBooks];
      if (!isClosed) emit(LibraryLoaded(updatedBooks)); // Instant UI update
    } else if (state is LibraryEmpty) {
      if (!isClosed) emit(LibraryLoaded([book])); // Instant UI update
    }

    // Then sync with backend
    final result = await addBookToLibraryUseCase(book);
    
    if (isClosed) return;
    
    result.fold(
      (failure) {
        // Rollback on error: Reload from server
        if (!isClosed) loadLibrary(forceRefresh: true);
        if (!isClosed) emit(LibraryError(failure.message));
      },
      (_) {
        // Confirm: Refresh to ensure consistency
        if (!isClosed) loadLibrary(forceRefresh: true);
      },
    );
  }

  Future<void> updateBook(BookEntity book) async {
    if (isClosed) return;
    
    // Optimistic Update: Update book immediately in UI
    if (state is LibraryLoaded) {
      final currentBooks = (state as LibraryLoaded).books;
      final updatedBooks = currentBooks.map((b) {
        return b.id == book.id ? book : b;
      }).toList();
      if (!isClosed) emit(LibraryLoaded(updatedBooks)); // Instant UI update
    }

    // Then sync with backend
    final result = await updateBookUseCase(book);
    
    if (isClosed) return;
    
    result.fold(
      (failure) {
        // Rollback on error: Reload from server
        if (!isClosed) loadLibrary(forceRefresh: true);
        if (!isClosed) emit(LibraryError(failure.message));
      },
      (_) {
        // Confirm: Refresh to ensure consistency
        if (!isClosed) loadLibrary(forceRefresh: true);
      },
    );
  }

  Future<void> deleteBook(String bookId) async {
    if (isClosed) return;
    
    // Optimistic Update: Remove book immediately from UI
    if (state is LibraryLoaded) {
      final currentBooks = (state as LibraryLoaded).books;
      final updatedBooks = currentBooks.where((b) => b.id != bookId).toList();
      
      if (updatedBooks.isEmpty) {
        if (!isClosed) emit(LibraryEmpty()); // Instant UI update
      } else {
        if (!isClosed) emit(LibraryLoaded(updatedBooks)); // Instant UI update
      }
    }

    // Then sync with backend
    final result = await deleteBookUseCase(bookId);
    
    if (isClosed) return;
    
    result.fold(
      (failure) {
        // Rollback on error: Reload from server
        if (!isClosed) loadLibrary(forceRefresh: true);
        if (!isClosed) emit(LibraryError(failure.message));
      },
      (_) {
        // Confirm: Refresh to ensure consistency
        if (!isClosed) loadLibrary(forceRefresh: true);
      },
    );
  }
}
