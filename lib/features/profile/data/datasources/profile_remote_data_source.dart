import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
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

      if (response == null) {
        // If profile missing, return basic info from Auth (Self-healing fallback)
        final user = supabaseClient.auth.currentUser;
        if (user != null && user.id == userId) {
          // Try to Create it
          try {
            await supabaseClient.from('profiles').upsert({
              'id': user.id,
              'full_name': user.userMetadata?['full_name'],
            });
          } catch (_) {}

          return ProfileModel(
            id: userId,
            fullName: user.userMetadata?['full_name'],
          );
        }
        // Fallback if no auth user (unlikely if called with authenticated user id)
        throw const ServerFailure('Profile not found');
      }

      return ProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
