import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/secrets/app_secrets.dart';
import 'core/di/injection_container.dart' as di;
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/update_password_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/library/presentation/cubit/library_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/quotes/presentation/cubit/quote_cubit.dart';
import 'core/widgets/main_navigation_screen.dart';
import 'core/widgets/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  await dotenv.load(fileName: ".env");

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

  // Initialize Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize DI
  await di.init(sharedPreferences);

  // Handle OAuth deep links
  _handleOAuthDeepLinks();

  runApp(const RefiApp());
}

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleOAuthDeepLinks() {
  final appLinks = AppLinks();

  // Listen for deep links (OAuth callbacks and password reset)
  appLinks.uriLinkStream.listen((uri) {
    debugPrint('🔗 Deep link received: $uri');

    // Handle Supabase OAuth callback
    final supabase = Supabase.instance.client;

    // Handle OAuth deep link callback (refi://auth-callback)
    if (uri.scheme == 'refi' && uri.host == 'auth-callback') {
      // Extract the session from the deep link URL
      supabase.auth.getSessionFromUrl(uri).then((_) {
        debugPrint('✅ OAuth session restored from deep link');
      }).catchError((err) {
        debugPrint('❌ Error restoring session from deep link: $err');
      });
    }
    // Handle password reset deep link (refi://reset-password)
    else if (uri.scheme == 'refi' && uri.host == 'reset-password') {
      // Extract the session from the password reset URL
      supabase.auth.getSessionFromUrl(uri).then((_) {
        debugPrint('✅ Password reset session restored from deep link');
        // Navigate to update password screen
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: di.sl<AuthCubit>(),
                child: const UpdatePasswordScreen(),
              ),
            ),
          );
        }
      }).catchError((err) {
        debugPrint('❌ Error restoring password reset session: $err');
      });
    }
    // Also handle Supabase callback URLs (if redirected)
    else if (uri.toString().contains('supabase.co/auth/v1/callback')) {
      supabase.auth.getSessionFromUrl(uri).then((_) {
        debugPrint('✅ OAuth session restored from Supabase callback');
      }).catchError((err) {
        debugPrint('❌ Error restoring session from callback: $err');
      });
    }
  }, onError: (err) {
    debugPrint('❌ Deep link error: $err');
  });
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
        navigatorKey: navigatorKey,
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
                current is AuthUnauthenticated ||
                current is AuthFirstTime;
          },
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainNavigationScreen();
            } else if (state is AuthFirstTime) {
              return const OnboardingScreen();
            } else if (state is AuthUnauthenticated) {
              return const LoginScreen();
            }

            // Initial/Loading states
            return const SplashPage();
          },
        ),
      ),
    );
  }
}
