import 'package:equatable/equatable.dart';

enum BookStatus { reading, completed, wishlist }

class BookDetailsState extends Equatable {
  final int currentPage;
  final int totalPages;
  final BookStatus status;
  final List<String> quotes; // Mock list of quotes
  final bool isUpdating;

  const BookDetailsState({
    this.currentPage = 0,
    this.totalPages = 0,
    this.status = BookStatus.reading,
    this.quotes = const [],
    this.isUpdating = false,
  });

  BookDetailsState copyWith({
    int? currentPage,
    int? totalPages,
    BookStatus? status,
    List<String>? quotes,
    bool? isUpdating,
  }) {
    return BookDetailsState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;
  int get percentage => (progress * 100).toInt();

  @override
  List<Object> get props => [
    currentPage,
    totalPages,
    status,
    quotes,
    isUpdating,
  ];
}
