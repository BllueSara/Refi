import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'core/widgets/main_navigation_screen.dart';
import 'core/widgets/fast_launch_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/secrets/app_secrets.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/library/presentation/cubit/library_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/quotes/presentation/cubit/quote_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnonKey,
    );
    debugPrint('✅ Supabase Initialized!');
  } catch (e) {
    debugPrint('❌ Supabase Init Failed: $e');
  }

  // Initialize DI
  await di.init();

  runApp(const RefiApp());

  // Keep splash screen for 0.5 seconds
  await Future.delayed(const Duration(milliseconds: 500));
  FlutterNativeSplash.remove();
}

class RefiApp extends StatelessWidget {
  const RefiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(create: (context) => di.sl<LibraryCubit>()..loadLibrary()),
        BlocProvider(create: (context) => di.sl<ScannerCubit>()),
        BlocProvider(create: (context) => di.sl<QuoteCubit>()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // themeMode: ThemeMode.dark, // Disabled Dark Mode as per request
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
        home: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return current is AuthAuthenticated ||
                current is AuthUnauthenticated;
          },
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainNavigationScreen();
            } else if (state is AuthUnauthenticated) {
              return const OnboardingScreen();
            }
            // Default initial state
            return const FastLaunchScreen();
          },
        ),
      ),
    );
  }
}
