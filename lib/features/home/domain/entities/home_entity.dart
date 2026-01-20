import 'package:equatable/equatable.dart';

class HomeBook extends Equatable {
  final String title;
  final String author;
  final String
  coverUrl; // For now use a reliable placeholder or local asset logic
  final double progress; // 0.0 to 1.0

  const HomeBook({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.progress,
  });

  @override
  List<Object?> get props => [title, author, coverUrl, progress];
}

class HomeData extends Equatable {
  final String username;
  final int streakDays;
  final int completedBooks;
  final int totalQuotes;
  final String topTag; // e.g. "أدب"
  final String? dailyQuote;
  final String? dailyQuoteAuthor;
  final List<HomeBook> currentlyReading;

  const HomeData({
    required this.username,
    required this.streakDays,
    required this.completedBooks,
    required this.totalQuotes,
    required this.topTag,
    this.dailyQuote,
    this.dailyQuoteAuthor,
    this.currentlyReading = const [],
  });

  bool get isEmpty =>
      currentlyReading.isEmpty && completedBooks == 0 && totalQuotes == 0;

  @override
  List<Object?> get props => [
    username,
    streakDays,
    completedBooks,
    totalQuotes,
    topTag,
    dailyQuote,
    dailyQuoteAuthor,
    currentlyReading,
  ];
}
