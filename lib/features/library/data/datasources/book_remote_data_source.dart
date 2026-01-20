import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
  Future<void> addBookToLibrary(BookModel book);
  Future<List<BookModel>> fetchUserLibrary();
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
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$query',
    );
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['items'] == null) return [];

        final List<dynamic> items = data['items'];
        return items.map((item) => BookModel.fromGoogleBooks(item)).toList();
      } else {
        throw ServerFailure('Google Books API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addBookToLibrary(BookModel book) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw const ServerFailure('User not authenticated');

    // Self-healing: Ensure profile exists
    try {
      final profile = await supabaseClient
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) {
        await supabaseClient.from('profiles').upsert({
          'id': user.id,
          'full_name': user.userMetadata?['full_name'],
        });
      }
    } catch (_) {}

    try {
      // 1. Prepare data
      final bookData = book.toSupabase(user.id);

      // 2. Check strict ID (UUID) vs Google ID
      String? existingId;
      bool isUuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(book.id);

      if (isUuid) {
        // It's an update to an existing local book
        existingId = book.id;
      } else {
        // It's a new book from Search (Google ID)
        // Check duplication by TITLE for this user
        // (Ideally we would check google_id if we stored it, but title is fallback)
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

      // 3. Upsert
      // If we found an ID, force it into the payload to trigger Update
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

      final List<dynamic> data = response;
      return data.map((json) => BookModel.fromSupabase(json)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
