import '../../domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  const QuoteModel({
    required super.id,
    required super.text,
    super.bookId,
    super.bookTitle,
    super.bookAuthor,
    super.bookCoverUrl,
    required super.feeling,
    super.notes,
    super.isFavorite,
    required super.createdAt,
    super.source = 'manual',
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      text: json['content'] as String, // DB uses 'content'
      bookId: json['book_id'] as String?,
      bookTitle: json['book_title'] as String?, // From join or manual
      bookAuthor: json['book_author'] as String?, // From join or manual
      bookCoverUrl: json['book_cover_url'] as String?, // From join
      feeling: json['emotion'] as String, // DB uses 'emotion'
      notes: json['personal_note'] as String?, // DB uses 'personal_note'
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      source: json['source'] as String? ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': text, // Map to DB field
      'book_id': bookId,
      'emotion': feeling, // Map to DB field
      'personal_note': notes, // Map to DB field
      'is_favorite': isFavorite,
      'source': source,
    };
  }
}
