import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
  Future<void> addBookToLibrary(BookModel book);
  Future<List<BookModel>> fetchUserLibrary();
  Future<void> deleteBook(String bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final SupabaseClient supabaseClient;
  final http.Client client;

  BookRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.client,
  });

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    // 1. Input Sanitization
    final sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) return [];

    // 2. API Optimization
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$sanitizedQuery&langRestrict=ar&orderBy=relevance&maxResults=20',
    );

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['items'] == null) return [];

        final List<dynamic> items = data['items'];

        // 3. Transformation & Validation
        var books = items
            .map((item) => BookModel.fromGoogleBooks(item))
            .where((b) =>
                b.title.isNotEmpty &&
                b.title != 'No Title' &&
                b.imageUrl != null &&
                b.imageUrl!.isNotEmpty)
            .toList();

        // 4. Smart Ranking (Levenshtein)
        final normalizedQuery = _normalizeArabic(sanitizedQuery);

        books.sort((a, b) {
          final distA = _getRelevanceScore(a.title, normalizedQuery);
          final distB = _getRelevanceScore(b.title, normalizedQuery);
          return distA.compareTo(distB);
        });

        return books;
      } else {
        throw ServerFailure('Google Books API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // --- Helper Methods ---

  String _sanitizeQuery(String input) {
    String text = input.trim();
    // Keep Arabic, English, Numbers, Spaces
    text = text.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
    return text;
  }

  String _normalizeArabic(String text) {
    String t = text;
    t = t.replaceAll(RegExp(r'[أإآ]'), 'ا');
    t = t.replaceAll('ة', 'ه');
    t = t.replaceAll('ى', 'ي');
    // Normalize Hamzas if needed, but usually minimal is enough
    return t.toLowerCase(); // Case insensitive for English
  }

  int _getRelevanceScore(String title, String query) {
    // Lower score is better (closer distance)
    final normalizedTitle = _normalizeArabic(title);

    // Priority 1: Exact Match
    if (normalizedTitle == query) return 0;

    // Priority 2: Starts With
    if (normalizedTitle.startsWith(query)) return 10;

    // Priority 3: Contains
    if (normalizedTitle.contains(query)) return 50;

    // Priority 4: Levenshtein Distance
    return 100 + _levenshtein(normalizedTitle, query);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  @override
  Future<void> addBookToLibrary(BookModel book) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const ServerFailure('User not authenticated');

    try {
      final bookData = book.toSupabase(user.id);

      // Check if book already exists for this user to update instead of insert
      String? existingId;

      // Try finding by UUID first if updating
      bool isUuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(book.id);

      if (isUuid) {
        existingId = book.id;
      } else {
        // Find by title for this user
        final duplicate = await supabaseClient
            .from('books')
            .select('id')
            .eq('user_id', user.id)
            .eq('title', book.title)
            .maybeSingle();

        if (duplicate != null) {
          existingId = duplicate['id'] as String;
        }
      }

      if (existingId != null) {
        bookData['id'] = existingId;
      }

      await supabaseClient.from('books').upsert(bookData);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<BookModel>> fetchUserLibrary() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const ServerFailure('User not authenticated');

    try {
      final response = await supabaseClient
          .from('books')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      return data.map((json) => BookModel.fromSupabase(json)).toList();
    } catch (e) {
      // Fallback for unexpected errors
      return [];
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const ServerFailure('User not authenticated');

    try {
      await supabaseClient
          .from('books')
          .delete()
          .eq('id', bookId)
          .eq('user_id', user.id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
