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
  final List<String> categories;

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
    this.categories = const [],
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
        categories,
      ];

  // Helper for display
  String get author => authors.isNotEmpty ? authors.first : 'Unknown Author';

  // Progress
  double get progress =>
      (pageCount != null && pageCount! > 0) ? (currentPage / pageCount!) : 0.0;
  int get progressPercentage => (progress * 100).toInt();

  BookEntity copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? imageUrl,
    double? rating,
    String? description,
    String? publishedDate,
    int? pageCount,
    BookStatus? status,
    int? currentPage,
    List<String>? categories,
  }) {
    return BookEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      publishedDate: publishedDate ?? this.publishedDate,
      pageCount: pageCount ?? this.pageCount,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      categories: categories ?? this.categories,
    );
  }
}
