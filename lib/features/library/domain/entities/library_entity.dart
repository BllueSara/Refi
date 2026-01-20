import 'package:equatable/equatable.dart';

enum ReadingStatus { reading, completed, wishlist }

class QuoteEntity extends Equatable {
  final String id;
  final String text;
  final int pageNumber;
  final String bookId;

  const QuoteEntity({
    required this.id,
    required this.text,
    required this.pageNumber,
    required this.bookId,
  });

  @override
  List<Object?> get props => [id, text, pageNumber, bookId];
}

class LibraryBookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final ReadingStatus status;
  final int currentPage;
  final int totalPages;
  final List<String> tags;
  final List<QuoteEntity> quotes;

  const LibraryBookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.status,
    required this.currentPage,
    required this.totalPages,
    required this.tags,
    this.quotes = const [],
  });

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;
  int get progressPercentage => (progress * 100).toInt();

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    coverUrl,
    status,
    currentPage,
    totalPages,
    tags,
    quotes,
  ];
}
