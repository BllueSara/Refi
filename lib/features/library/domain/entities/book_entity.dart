import 'package:equatable/equatable.dart';

enum BookStatus { reading, completed, wishlist, none }

class BookEntity extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String? imageUrl;
  final double? rating;
  final String? description;
  final String? publishedDate;
  final int? pageCount;

  // User specific fields
  final BookStatus status;
  final int currentPage;

  const BookEntity({
    required this.id,
    required this.title,
    required this.authors,
    this.imageUrl,
    this.rating,
    this.description,
    this.publishedDate,
    this.pageCount,
    this.status = BookStatus.none,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    authors,
    imageUrl,
    rating,
    description,
    publishedDate,
    pageCount,
    status,
    currentPage,
  ];

  // Helper for display
  String get author => authors.isNotEmpty ? authors.first : 'Unknown Author';

  // Progress
  double get progress =>
      (pageCount != null && pageCount! > 0) ? (currentPage / pageCount!) : 0.0;
  int get progressPercentage => (progress * 100).toInt();
}
