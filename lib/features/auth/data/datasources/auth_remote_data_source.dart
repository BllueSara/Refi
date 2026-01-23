import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithGoogle();

  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerFailure('Login failed: User is null');
      }

      // Fetch profile data optionally
      final profile = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      final String? name = profile != null
          ? profile['full_name']
          : response.user!.userMetadata?['full_name'];

      // Self-healing: Ensure profile exists
      if (profile == null) {
        try {
          await supabaseClient.from('profiles').upsert({
            'id': response.user!.id,
            'email': email, // Using email from login arg
            'full_name': name,
            'annual_goal': 0,
          });
        } catch (_) {}
      }

      return UserModel.fromSupabase(response.user!, name: name);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name}, // Store in metadata too
      );

      if (response.user == null) {
        throw const ServerFailure('Sign up failed: User is null');
      }

      try {
        await supabaseClient.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': name,
          'annual_goal': 0,
        });
      } catch (e) {
        // Log error
      }

      return UserModel.fromSupabase(response.user!, name: name);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        try {
          await googleSignIn.signOut();
        } catch (_) {}
      }
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      try {
        final profile = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        final String? name = profile != null
            ? profile['full_name']
            : user.userMetadata?['full_name'];

        // Self-healing check (only if profile is missing)
        if (profile == null) {
          try {
            await supabaseClient.from('profiles').upsert({
              'id': user.id,
              'full_name': name,
              'annual_goal': 0,
            });
          } catch (_) {}
        }

        return UserModel.fromSupabase(user, name: name);
      } catch (_) {
        return UserModel.fromSupabase(user);
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const ServerFailure('Google Sign In was canceled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerFailure('No ID Token found from Google');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const ServerFailure(
          'Supabase Google Sign In failed: User is null',
        );
      }

      final String? name =
          response.user!.userMetadata?['full_name'] ?? googleUser.displayName;

      try {
        await supabaseClient.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': name,
          'avatar_url': googleUser.photoUrl,
          'annual_goal': 0,
        });
      } catch (_) {}

      return UserModel.fromSupabase(response.user!, name: name);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
