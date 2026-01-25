import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.authors,
    super.imageUrl,
    super.rating,
    super.description,
    super.publishedDate,
    super.pageCount,
    super.status,
    super.currentPage,
    super.categories,
    super.googleBookId,
    super.source,
  });

  factory BookModel.fromGoogleBooks(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    List<String> authors = [];
    if (volumeInfo['authors'] != null) {
      authors = List<String>.from(volumeInfo['authors']);
    }
    List<String> categories = [];
    if (volumeInfo['categories'] != null) {
      categories = List<String>.from(volumeInfo['categories']);
    }

    double? rating;
    if (volumeInfo['averageRating'] != null) {
      rating = (volumeInfo['averageRating'] as num).toDouble();
    }

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'No Title',
      authors: authors,
      imageUrl: imageLinks['thumbnail']?.toString().replaceFirst(
            'http:',
            'https:',
          ),
      rating: rating,
      description: volumeInfo['description'],
      publishedDate: volumeInfo['publishedDate'],
      pageCount: volumeInfo['pageCount'],
      // Default for search result
      status: BookStatus.none,
      currentPage: 0,
      categories: categories,
      googleBookId: json['id'],
      source: 'google',
    );
  }

  factory BookModel.fromSupabase(Map<String, dynamic> json) {
    BookStatus status = BookStatus.none;
    if (json['status'] != null) {
      try {
        status = BookStatus.values.firstWhere((e) => e.name == json['status']);
      } catch (_) {}
    }

    // Map single author string to List as per schema: 'author' text
    List<String> authorsList = [];
    if (json['author'] != null && json['author'] is String) {
      authorsList = [json['author']];
    } else if (json['authors'] != null) {
      authorsList = List<String>.from(json['authors']);
    }

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      authors: authorsList,
      imageUrl: json['cover_url'] ?? json['image_url'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      description: json['description'],
      publishedDate: json['published_date'],
      pageCount: json['total_pages'] ?? json['page_count'],
      status: status,
      currentPage: json['current_page'] ?? 0,
      categories:
          (json['categories'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      googleBookId: json['google_book_id'],
      source: json['source'] ?? 'manual',
    );
  }

  Map<String, dynamic> toSupabase(String userId) {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'title': title,
      'author': authors.isNotEmpty ? authors.first : null,
      'cover_url': imageUrl,
      'status': status == BookStatus.none ? 'wishlist' : status.name,
      'total_pages': pageCount ?? 0,
      'current_page': currentPage,
      'rating': rating,
      'categories': categories,
    };

    // Add source and google_book_id if they exist
    if (googleBookId != null) data['google_book_id'] = googleBookId;
    if (source != null) data['source'] = source;

    return data;
  }
}
