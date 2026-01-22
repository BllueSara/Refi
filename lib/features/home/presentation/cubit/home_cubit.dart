import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/home_entity.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../library/domain/usecases/fetch_user_library_usecase.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../quotes/domain/usecases/get_user_quotes_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetProfileUseCase getProfileUseCase;
  final FetchUserLibraryUseCase fetchUserLibraryUseCase;
  final GetUserQuotesUseCase getUserQuotesUseCase;
  final SupabaseClient supabaseClient;

  HomeCubit({
    required this.getProfileUseCase,
    required this.fetchUserLibraryUseCase,
    required this.getUserQuotesUseCase,
    required this.supabaseClient,
  }) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      emit(
        HomeEmpty(
          const HomeData(
            username: "...",
            streakDays: 0,
            completedBooks: 0,
            totalQuotes: 0,
            topTag: "",
          ),
        ),
      );
      return;
    }

    try {
      // 1. Fetch Profile
      // GetProfileUseCase here expects userId.
      final profileResult = await getProfileUseCase(userId);
      String username = "يا صديقي";
      int streak = 0;
      int? annualGoal;

      profileResult.fold((l) {}, (profile) {
        username = profile.fullName ?? "قارئ";
        streak = profile.currentStreak ?? 0;
        annualGoal = profile.annualGoal; // Extracted from profile
      });

      // 2. Fetch Books
      final libraryResult = await fetchUserLibraryUseCase();
      int completedBooks = 0;
      List<HomeBook> currentlyReading = [];

      libraryResult.fold((l) {}, (books) {
        completedBooks =
            books.where((b) => b.status == BookStatus.completed).length;
        currentlyReading = books
            .where((b) => b.status == BookStatus.reading)
            .map(
              (b) => HomeBook(
                title: b.title,
                author: b.author,
                coverUrl: b.imageUrl ?? '',
                progress: b.currentPage /
                    (b.pageCount == 0 || b.pageCount == null
                        ? 1
                        : b.pageCount!),
              ),
            )
            .toList();
      });

      // 3. Fetch Quotes (Only for statistics count now)
      final quotesResult = await getUserQuotesUseCase();
      int totalQuotes = 0;

      quotesResult.fold((l) {}, (quotes) {
        totalQuotes = quotes.length;
      });

      final homeData = HomeData(
        username: username,
        streakDays: streak,
        completedBooks: completedBooks,
        totalQuotes: totalQuotes,
        topTag: "قراءة", // Placeholder
        annualGoal: annualGoal,
        currentlyReading: currentlyReading,
      );

      if (homeData.isEmpty) {
        emit(HomeEmpty(homeData));
      } else {
        emit(HomeLoaded(homeData));
      }
    } catch (e) {
      // Fallback
      emit(
        HomeEmpty(
          const HomeData(
            username: "...",
            streakDays: 0,
            completedBooks: 0,
            totalQuotes: 0,
            topTag: "",
          ),
        ),
      );
    }
  }

  Future<void> updateAnnualGoal(int newGoal) async {
    final currentState = state;
    HomeData? currentData;

    if (currentState is HomeLoaded) {
      currentData = currentState.data;
    } else if (currentState is HomeEmpty) {
      currentData = currentState.data;
    }

    if (currentData != null) {
      // Optimistic Update
      final updatedData = currentData.copyWith(annualGoal: newGoal);
      emit(HomeLoaded(updatedData)); // Always emit Loaded to show data

      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        try {
          await supabaseClient
              .from('profiles')
              .update({'annual_goal': newGoal}).eq('id', userId);
        } catch (e) {
          // Revert on failure (silent or show error)
          emit(currentState);
        }
      }
    }
  }
}
