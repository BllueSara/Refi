import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<void> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
    bool isFavorite = false,
  });

  Future<List<QuoteModel>> getUserQuotes();
  Future<List<QuoteModel>> getBookQuotes(String bookId);
  Future<void> toggleFavorite(
      {required String quoteId, required bool isFavorite});
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final SupabaseClient supabaseClient;

  QuoteRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> saveQuote({
    required String text,
    String? bookId,
    required String feeling,
    String? notes,
    bool isFavorite = false,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    print('🔍 Saving quote: userId=$userId, bookId=$bookId, feeling=$feeling');

    try {
      await supabaseClient.from('quotes').insert({
        'user_id': userId,
        'content': text,
        'book_id': bookId,
        'emotion': feeling,
        'personal_note': notes,
        'is_favorite': isFavorite,
      });
      print('✅ Quote saved successfully!');
    } catch (e) {
      print('❌ Error saving quote: $e');
      rethrow;
    }
  }

  @override
  Future<List<QuoteModel>> getUserQuotes() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabaseClient
        .from('quotes')
        .select('*, books(title, author, cover_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      // Extract book info from join
      String? bookTitle;
      String? bookAuthor;
      String? bookCoverUrl;
      if (json['books'] != null) {
        bookTitle = json['books']['title'];
        bookAuthor = json['books']['author'];
        bookCoverUrl = json['books']['cover_url'];
      }

      return QuoteModel.fromJson({
        ...json,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'book_cover_url': bookCoverUrl,
      });
    }).toList();
  }

  @override
  Future<List<QuoteModel>> getBookQuotes(String bookId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabaseClient
        .from('quotes')
        .select('*, books(title, author, cover_url)')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      String? bookTitle;
      String? bookAuthor;
      String? bookCoverUrl;
      if (json['books'] != null) {
        bookTitle = json['books']['title'];
        bookAuthor = json['books']['author'];
        bookCoverUrl = json['books']['cover_url'];
      }

      return QuoteModel.fromJson({
        ...json,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'book_cover_url': bookCoverUrl,
      });
    }).toList();
  }

  @override
  Future<void> toggleFavorite({
    required String quoteId,
    required bool isFavorite,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await supabaseClient
          .from('quotes')
          .update({'is_favorite': isFavorite})
          .eq('id', quoteId)
          .eq('user_id', userId);
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      rethrow;
    }
  }
}
