import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/home_entity.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../library/domain/usecases/fetch_user_library_usecase.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../quotes/domain/usecases/get_user_quotes_usecase.dart';
import '../../../../core/services/goal_achievement_tracker.dart';
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

  Future<void> loadHomeData({bool forceRefresh = false}) async {
    if (isClosed) return;
    
    // 1. Smart Cache Check
    if (!forceRefresh) {
      if (state is HomeLoaded) {
        // Data exists, don't show loading. Just refresh in background.
      } else if (state is HomeInitial) {
        if (!isClosed) emit(HomeLoading());
      }
    } else {
      // Manual refresh, can show loading or small indicator (UI handles pulled refresh)
      // If pulled-to-refresh, UI usually shows the spinner, so we don't necessarily need to emit HomeLoading which triggers full screen skeleton.
      // However, if we want to blocking load, we emit loading.
      // Given "avoid redundant loading screens", we generally avoid emitting HomeLoading if we have data.
      if (state is! HomeLoaded && state is! HomeEmpty) {
        if (!isClosed) emit(HomeLoading());
      }
    }

    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      if (!isClosed) {
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

      // Check if goal is achieved and not yet celebrated
      final isGoalAchieved = GoalAchievementTracker.isGoalAchieved(
        completedBooks,
        annualGoal,
      );
      final hasCelebrated = await GoalAchievementTracker.hasCelebratedThisYear();

      if (isClosed) return;

      if (isGoalAchieved && !hasCelebrated) {
        // Emit special state to trigger celebration
        if (!isClosed) emit(HomeGoalAchieved(homeData));
      } else if (homeData.isEmpty) {
        if (!isClosed) emit(HomeEmpty(homeData));
      } else {
        if (!isClosed) emit(HomeLoaded(homeData));
      }
    } catch (e) {
      if (isClosed) return;
      
      // On Error, if we have data, keep it.
      if (state is HomeLoaded) {
        // Optionally emit an error side-effect if we had a way, but for now just keep previous state is better than wiping key data.
        return;
      }

      // Fallback only if no data
      if (!isClosed) {
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
  }

  Future<void> updateAnnualGoal(int newGoal) async {
    if (isClosed) return;
    
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
      if (!isClosed) emit(HomeLoaded(updatedData)); // Always emit Loaded to show data

      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        try {
          await supabaseClient
              .from('profiles')
              .update({'annual_goal': newGoal}).eq('id', userId);
        } catch (e) {
          // Revert on failure (silent or show error)
          if (!isClosed) emit(currentState);
        }
      }
    }
  }

  /// Mark goal achievement as celebrated and transition to loaded state
  Future<void> markGoalAsCelebrated() async {
    await GoalAchievementTracker.markAsCelebrated();
    
    final currentState = state;
    if (currentState.runtimeType.toString() == 'HomeGoalAchieved') {
      // Transition to normal loaded state
      final goalState = currentState as dynamic;
      emit(HomeLoaded(goalState.data));
    }
  }
}
