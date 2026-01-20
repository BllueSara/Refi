import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/library_entity.dart';
import '../../../../core/constants/app_strings.dart';

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
  final List<LibraryBookEntity> allBooks;
  final List<LibraryBookEntity> filteredBooks;
  final String activeTab;

  const LibraryLoaded({
    required this.allBooks,
    required this.filteredBooks,
    this.activeTab = AppStrings.tabAll,
  });

  @override
  List<Object> get props => [allBooks, filteredBooks, activeTab];
}

// Cubit
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit() : super(LibraryInitial());

  // Mock Data Loading
  void loadLibrary({bool isEmpty = false}) async {
    emit(LibraryLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate API

    if (isEmpty) {
      emit(LibraryEmpty());
    } else {
      final mockBooks = [
        const LibraryBookEntity(
          id: "1",
          title: "قوة العادات",
          author: "تشارلز ديويج",
          status: ReadingStatus.reading,
          currentPage: 240,
          totalPages: 370,
          tags: [AppStrings.catSelfHelp, AppStrings.catDevelopment],
          quotes: [],
        ),
        LibraryBookEntity(
          id: "2",
          title:
              "فن اللامبالاة", // Using English text for variety if needed but adhering to Arabic
          author: "مارك مانسون",
          status: ReadingStatus.completed,
          currentPage: 200,
          totalPages: 200,
          tags: [AppStrings.catSelfHelp],
        ),
        LibraryBookEntity(
          id: "3",
          title: "الخيميائي",
          author: "باولو كويلو",
          status: ReadingStatus.wishlist,
          currentPage: 0,
          totalPages: 180,
          tags: [AppStrings.catNovel],
        ),
      ];
      emit(LibraryLoaded(allBooks: mockBooks, filteredBooks: mockBooks));
    }
  }

  void filterBooks(String tab) {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      List<LibraryBookEntity> filtered;

      switch (tab) {
        case AppStrings.tabReading:
          filtered = currentState.allBooks
              .where((b) => b.status == ReadingStatus.reading)
              .toList();
          break;
        case AppStrings.tabCompleted:
          filtered = currentState.allBooks
              .where((b) => b.status == ReadingStatus.completed)
              .toList();
          break;
        case AppStrings.tabWishlist:
          filtered = currentState.allBooks
              .where((b) => b.status == ReadingStatus.wishlist)
              .toList();
          break;
        case AppStrings.tabAll:
        default:
          filtered = currentState.allBooks;
          break;
      }

      emit(
        LibraryLoaded(
          allBooks: currentState.allBooks,
          filteredBooks: filtered,
          activeTab: tab,
        ),
      );
    }
  }
}
