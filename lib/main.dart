import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const RefiApp());
}

class RefiApp extends StatelessWidget {
  const RefiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Localization setup for RTL
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'), // Arabic
        Locale('en', 'US'), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OnboardingScreen(),
    );
  }
}
