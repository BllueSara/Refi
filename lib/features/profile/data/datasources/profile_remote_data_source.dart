import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    int? annualGoal,
    String? avatarUrl,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final booksCountResponse = await supabaseClient
          .from('books')
          .count()
          .eq('user_id', userId)
          .eq('status', 'completed'); // Schema says 'completed'

      int finishedBooks = booksCountResponse; // count() returns int

      // Fetch quotes count
      final quotesCountResponse =
          await supabaseClient.from('quotes').count().eq('user_id', userId);

      int totalQuotes = quotesCountResponse;

      if (response == null) {
        // ... (existing fallback logic) ...
        // Note: For fallback, finishedBooks will be 0 or count from books
        final user = supabaseClient.auth.currentUser;
        // ... (existing upsert logic) ...

        return ProfileModel(
          id: userId,
          fullName: user?.userMetadata?['full_name'],
          finishedBooksCount: finishedBooks,
          totalQuotesCount: totalQuotes,
        );
      }

      return ProfileModel.fromSupabase({
        ...response,
        'finished_books_count': finishedBooks,
        'total_quotes_count': totalQuotes,
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    int? annualGoal,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (annualGoal != null) updates['annual_goal'] = annualGoal;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) return;

      await supabaseClient.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
