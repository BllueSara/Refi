import 'dart:async';
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
  Future<void> updatePassword(String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> resetPassword(String email) async {
    try {
      // Use deep link for password reset redirect to avoid localhost
      // Make sure 'refi://reset-password' is added in Supabase Dashboard → Redirect URLs
      const redirectTo = 'refi://reset-password';
      
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
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
      // Use Supabase OAuth flow - Supabase handles all Google OAuth configuration
      // For mobile apps: Use deep link directly to avoid localhost redirect
      // IMPORTANT: Make sure 'refi://auth-callback' is added in Supabase Dashboard → Redirect URLs
      const redirectUrl = 'refi://auth-callback';
      
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // The OAuth flow will redirect to Google, then back to the app via deep link
      // The deep link handler in main.dart will process the callback
      // We need to wait for the auth state to change
      // Use a stream subscription to wait for authentication
      final completer = Completer<UserModel>();
      late StreamSubscription<AuthState> subscription;
      
      subscription = supabaseClient.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn && session != null) {
          final user = session.user;
          
          // Fetch or create profile
          supabaseClient.from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle()
              .then((profile) {
            final String? name = user.userMetadata?['full_name'] ?? 
                                user.userMetadata?['name'] ??
                                user.email?.split('@').first;

            if (profile == null) {
              supabaseClient.from('profiles').upsert({
                'id': user.id,
                'full_name': name,
                'avatar_url': user.userMetadata?['avatar_url'],
                'annual_goal': 0,
              }).then((_) {
                subscription.cancel();
                completer.complete(UserModel.fromSupabase(user, name: name));
              }).catchError((e) {
                subscription.cancel();
                completer.complete(UserModel.fromSupabase(user, name: name));
              });
            } else {
              subscription.cancel();
              completer.complete(UserModel.fromSupabase(user, name: name));
            }
          }).catchError((e) {
            subscription.cancel();
            final String? name = user.userMetadata?['full_name'] ?? 
                                user.userMetadata?['name'] ??
                                user.email?.split('@').first;
            completer.complete(UserModel.fromSupabase(user, name: name));
          });
        } else if (event == AuthChangeEvent.signedOut) {
          subscription.cancel();
          if (!completer.isCompleted) {
            completer.completeError(const ServerFailure('Google Sign In was canceled'));
          }
        }
      });

      // Wait for authentication with timeout
      return await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          subscription.cancel();
          throw const ServerFailure('Google Sign In timed out');
        },
      );
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
