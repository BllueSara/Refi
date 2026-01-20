import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/home_entity.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../library/domain/usecases/fetch_user_library_usecase.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../quotes/domain/usecases/get_user_quotes_usecase.dart';
import 'home_state.dart';
import 'dart:math';

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

      profileResult.fold((l) {}, (profile) {
        username = profile.fullName ?? "قارئ";
        streak = profile.currentStreak ?? 0;
      }); // 2. Fetch Books
      final libraryResult = await fetchUserLibraryUseCase();
      int completedBooks = 0;
      List<HomeBook> currentlyReading = [];

      libraryResult.fold((l) {}, (books) {
        completedBooks = books
            .where((b) => b.status == BookStatus.completed)
            .length;
        currentlyReading = books
            .where((b) => b.status == BookStatus.reading)
            .map(
              (b) => HomeBook(
                title: b.title,
                author: b.author,
                coverUrl: b.imageUrl ?? '',
                progress:
                    (b.currentPage ?? 0) /
                    (b.pageCount == 0 || b.pageCount == null
                        ? 1
                        : b.pageCount!),
              ),
            )
            .toList();
      });

      // 3. Fetch Quotes
      final quotesResult = await getUserQuotesUseCase();
      int totalQuotes = 0;
      String? dailyQuote;
      String? dailyQuoteAuthor;

      quotesResult.fold((l) {}, (quotes) {
        totalQuotes = quotes.length;
        if (quotes.isNotEmpty) {
          // Pick random quote
          final random = Random();
          final quote = quotes[random.nextInt(quotes.length)];
          dailyQuote = quote.text;
          dailyQuoteAuthor = quote.bookAuthor ?? "مجهول";
        }
      });

      final homeData = HomeData(
        username: username,
        streakDays: streak,
        completedBooks: completedBooks,
        totalQuotes: totalQuotes,
        topTag: "قراءة", // Placeholder
        dailyQuote: dailyQuote,
        dailyQuoteAuthor: dailyQuoteAuthor,
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
}
