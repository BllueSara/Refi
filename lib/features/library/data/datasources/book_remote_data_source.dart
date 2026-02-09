import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/secrets/app_secrets.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
  Future<BookModel> addBookToLibrary(BookModel book);
  Future<List<BookModel>> fetchUserLibrary();
  Future<void> deleteBook(String bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final SupabaseClient supabaseClient;
  final http.Client client;

  // Rate limiting: Track last request time
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 500);

  // Cache for search results (simple in-memory cache)
  final Map<String, List<BookModel>> _searchCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);
  final Map<String, DateTime> _cacheTimestamps = {};

  BookRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.client,
  });

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    // 1. Input Sanitization
    final sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) return [];

    // 2. Check cache first
    final cacheKey = sanitizedQuery.toLowerCase().trim();
    if (_searchCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheExpiry) {
        return _searchCache[cacheKey]!;
      } else {
        // Cache expired, remove it
        _searchCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    // 3. Rate limiting: Ensure minimum time between requests
    await _enforceRateLimit();

    // 4. Build URL with API Key if available
    final apiKey = AppSecrets.googleBooksApiKey.isNotEmpty
        ? '&key=${Uri.encodeComponent(AppSecrets.googleBooksApiKey)}'
        : '';
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(sanitizedQuery)}&langRestrict=ar&orderBy=relevance&maxResults=20$apiKey',
    );

    // 5. Retry logic with exponential backoff
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await client.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['items'] == null) {
            // Cache empty result
            _searchCache[cacheKey] = [];
            _cacheTimestamps[cacheKey] = DateTime.now();
            return [];
          }

          final List<dynamic> items = data['items'];

          // 6. Transformation & Validation
          var books = items
              .map((item) => BookModel.fromGoogleBooks(item))
              .where((b) =>
                  b.title.isNotEmpty &&
                  b.title != 'No Title' &&
                  b.imageUrl != null &&
                  b.imageUrl!.isNotEmpty)
              .toList();

          // 7. Smart Ranking (Levenshtein)
          final normalizedQuery = _normalizeArabic(sanitizedQuery);

          books.sort((a, b) {
            final distA = _getRelevanceScore(a.title, normalizedQuery);
            final distB = _getRelevanceScore(b.title, normalizedQuery);
            return distA.compareTo(distB);
          });

          // 8. Cache the result
          _searchCache[cacheKey] = books;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return books;
        } else if (response.statusCode == 429) {
          // Rate limit exceeded - exponential backoff
          retryCount++;
          if (retryCount >= maxRetries) {
            throw ServerFailure(
              'تم تجاوز الحد المسموح من طلبات البحث. يرجى المحاولة بعد قليل.',
            );
          }

          // Exponential backoff: 2^retryCount seconds
          final waitTime = Duration(seconds: 1 << retryCount);
          await Future.delayed(waitTime);

          // Also enforce rate limit after waiting
          await _enforceRateLimit();
          continue;
        } else {
          throw ServerFailure(
            'Google Books API Error: ${response.statusCode}. ${response.statusCode == 403 ? "يرجى التحقق من API Key" : ""}',
          );
        }
      } catch (e) {
        // If it's a ServerFailure, rethrow it
        if (e is ServerFailure) {
          rethrow;
        }

        // For network errors, retry with exponential backoff
        retryCount++;
        if (retryCount >= maxRetries) {
          throw ServerFailure(
            'فشل الاتصال بخدمة البحث. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
          );
        }

        final waitTime = Duration(seconds: 1 << retryCount);
        await Future.delayed(waitTime);
      }
    }

    throw ServerFailure('فشل البحث بعد عدة محاولات');
  }

  /// Enforces rate limiting by waiting if necessary
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();
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
  Future<BookModel> addBookToLibrary(BookModel book) async {
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

      final response =
          await supabaseClient.from('books').upsert(bookData).select().single();

      return BookModel.fromSupabase(response);
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
