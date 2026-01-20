import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/home_entity.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHomeData({bool isNewUser = false}) async {
    emit(HomeLoading());

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    if (isNewUser) {
      final emptyData = const HomeData(
        username: "سارة",
        streakDays: 0,
        completedBooks: 0,
        totalQuotes: 0,
        topTag: "",
        currentlyReading: [],
      );
      emit(HomeEmpty(emptyData));
    } else {
      final populatedData = const HomeData(
        username: "سارة",
        streakDays: 7,
        completedBooks: 14,
        totalQuotes: 128,
        topTag: "أدب",
        dailyQuote:
            "القراءة هي حياة ثانية نعيشها لنتعلم كيف نعيش الحياة الأولى.",
        dailyQuoteAuthor: "عباس محمود العقاد",
        currentlyReading: [
          HomeBook(
            title: "الخيميائي",
            author: "باولو كويلو",
            coverUrl:
                "assets/images/book_placeholder_1.png", // Start thinking about assets
            progress: 0.45,
          ),
          HomeBook(
            title: "قواعد العشق الأربعون",
            author: "إليف شافاق",
            coverUrl: "assets/images/book_placeholder_2.png",
            progress: 0.12,
          ),
        ],
      );
      emit(HomeLoaded(populatedData));
    }
  }
}
