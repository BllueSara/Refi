import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets/app_secrets.dart';

/// Service for sending notifications via Telegram Bot
/// This is optional and only works if Telegram credentials are configured
class TelegramNotificationService {
  final http.Client client;

  TelegramNotificationService({required this.client});

  /// Send a notification to Telegram
  /// Returns true if successful, false otherwise (fails silently if not configured)
  Future<bool> sendNotification(String message) async {
    // Skip if Telegram is not configured
    if (AppSecrets.telegramBotToken.isEmpty || 
        AppSecrets.telegramChatId.isEmpty) {
      return false;
    }

    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot${AppSecrets.telegramBotToken}/sendMessage',
      );

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': AppSecrets.telegramChatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Fail silently - notification is optional
      return false;
    }
  }

  /// Format contact message for Telegram
  String formatContactMessage({
    required String subject,
    required String message,
    String? userName,
    String? userEmail,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📩 <b>رسالة جديدة من جليس</b>\n');
    
    if (userName != null && userName.isNotEmpty) {
      buffer.writeln('👤 <b>الاسم:</b> $userName');
    }
    
    if (userEmail != null && userEmail.isNotEmpty) {
      buffer.writeln('📧 <b>البريد:</b> $userEmail');
    }
    
    buffer.writeln('📌 <b>الموضوع:</b> $subject');
    buffer.writeln('\n💬 <b>الرسالة:</b>');
    buffer.writeln(message);
    
    return buffer.toString();
  }
}

