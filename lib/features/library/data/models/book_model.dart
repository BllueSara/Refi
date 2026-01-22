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
    );
  }

  factory BookModel.fromSupabase(Map<String, dynamic> json) {
    BookStatus status = BookStatus.none;
    if (json['status'] != null) {
      try {
        status = BookStatus.values.firstWhere((e) => e.name == json['status']);
      } catch (_) {}
    }

    // Map single author string to List
    List<String> authorsList = [];
    if (json['author'] != null && json['author'] is String) {
      authorsList = [json['author']];
    } else if (json['authors'] != null) {
      // Fallback if user changed schema back or mixed
      authorsList = List<String>.from(json['authors']);
    }
    /* 
    List<String> categories = [];
    if (json['categories'] != null) {
       // Handle simple array
       categories = List<String>.from(json['categories']);
    }
    */

    return BookModel(
      id: json['id']?.toString() ?? '', // Supabase UUID
      title: json['title'] ?? '',
      authors: authorsList,
      imageUrl:
          json['cover_url'] ?? json['image_url'], // Support schema 'cover_url'
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      description: null, // Not in schema
      publishedDate: null, // Not in schema
      pageCount:
          json['total_pages'] ?? json['page_count'], // Schema 'total_pages'
      status: status,
      currentPage: json['current_page'] ?? 0,
      categories: const [], // categories,
    );
  }

  Map<String, dynamic> toSupabase(String userId) {
    // Schema based properties
    return {
      'user_id': userId,
      // 'id': auto-generated uuid by db
      'title': title,
      'author': authors.isNotEmpty
          ? authors.first
          : null, // Schema has singular 'author' text
      'cover_url': imageUrl, // Schema 'cover_url'
      'status': status == BookStatus.none
          ? 'wishlist' // Default as per schema default
          : status.name,
      'total_pages': pageCount, // Schema 'total_pages'
      'current_page': currentPage,
      'rating': rating,
      // 'categories': categories,
      // 'created_at': default now()
    };
  }
}
