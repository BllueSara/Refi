class AppSecrets {
  // ⚠️ IMPORTANT: Replace these with your actual Supabase keys
  // Go to: https://supabase.com/dashboard/project/_/settings/api

  static const String supabaseUrl = 'https://thfehrycowozthjkzjuv.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_ZTHCMuPGinHwlEIjfFADow_X7yOQmkp';

  // Google Books API Key
  // Get your API key from: https://console.cloud.google.com/apis/credentials
  // Enable "Books API" in Google Cloud Console first
  static const String googleBooksApiKey =
      'AIzaSyAtC8Hr8yqZpO0T0fjSzNJYayWV-zBBYMI'; // TODO: Add your Google Books API Key here

  // Telegram Bot Configuration (Optional - for Contact Us notifications)
  // 1. Create bot: Open Telegram → search @BotFather → /newbot
  // 2. Get your bot token from BotFather
  // 3. Get chat ID: Send message to your bot, then visit:
  //    https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
  static const String telegramBotToken = ''; // TODO: Add your Telegram Bot Token here
  static const String telegramChatId = ''; // TODO: Add your Chat ID here

  // Note: Google OAuth is handled by Supabase, no need for googleServerClientId
  // Make sure to configure Google OAuth in your Supabase dashboard:
  // https://supabase.com/dashboard/project/_/auth/providers
}
