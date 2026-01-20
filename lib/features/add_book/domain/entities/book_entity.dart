import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final double rating;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.rating = 0.0,
  });

  @override
  List<Object?> get props => [id, title, author, coverUrl, rating];
}
