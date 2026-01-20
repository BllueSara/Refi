import 'package:equatable/equatable.dart';

class QuoteEntity extends Equatable {
  final String id;
  final String text;
  final String? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String feeling;
  final String? notes;
  final DateTime createdAt;

  const QuoteEntity({
    required this.id,
    required this.text,
    this.bookId,
    this.bookTitle,
    this.bookAuthor,
    required this.feeling,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    bookId,
    bookTitle,
    bookAuthor,
    feeling,
    notes,
    createdAt,
  ];
}
