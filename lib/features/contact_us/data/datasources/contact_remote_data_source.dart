import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact_message_model.dart';

abstract class ContactRemoteDataSource {
  Future<void> sendContactMessage(ContactMessageModel message);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final SupabaseClient supabaseClient;

  ContactRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> sendContactMessage(ContactMessageModel message) async {
    try {
      // Get current user if authenticated
      final currentUser = supabaseClient.auth.currentUser;
      
      // Prepare message data
      final messageData = message.toSupabase();
      
      // Add user info if available
      if (currentUser != null) {
        messageData['user_id'] = currentUser.id;
        messageData['user_email'] = currentUser.email;
        
        // Try to get user name from profiles table
        try {
          final profile = await supabaseClient
              .from('profiles')
              .select('full_name')
              .eq('id', currentUser.id)
              .single();
          
          if (profile['full_name'] != null) {
            messageData['user_name'] = profile['full_name'];
          }
        } catch (e) {
          // If profile fetch fails, try getting name from user metadata
          final name = currentUser.userMetadata?['full_name'] ?? 
                       currentUser.userMetadata?['name'] ??
                       currentUser.email?.split('@').first;
          if (name != null) {
            messageData['user_name'] = name;
          }
        }
      }
      
      // Insert message into database
      await supabaseClient.from('contact_messages').insert(messageData);
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: ${e.toString()}');
    }
  }
}

