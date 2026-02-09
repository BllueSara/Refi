import 'dart:async'; // Added for StreamSubscription
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
import 'core/services/subscription_manager.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/update_password_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/library/presentation/cubit/library_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/quotes/presentation/cubit/quote_cubit.dart';
import 'core/widgets/main_navigation_screen.dart';
import 'core/widgets/splash_page.dart';
import 'core/widgets/network_aware_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ Warning: Could not load .env file: $e');
    // Continue without .env - some features might not work but app won't crash
  }

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

  // Initialize RevenueCat (Blocking, ensure it's ready before app starts)
  try {
    await di.sl<SubscriptionManager>().init();
    debugPrint('✅ RevenueCat Initialized Successfully in main()');
  } catch (e, stackTrace) {
    debugPrint('❌ RevenueCat Init Failed in main(): $e');
    debugPrint('   Stack trace: $stackTrace');
    // Continue anyway - app can work without RevenueCat, but subscriptions won't work
    // User can retry initialization later from the test button
  }

  // Handle OAuth deep links - Logic moved to RefiApp
  // _handleOAuthDeepLinks();

  runApp(const RefiApp());
}

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RefiApp extends StatefulWidget {
  const RefiApp({super.key});

  @override
  State<RefiApp> createState() => _RefiAppState();
}

class _RefiAppState extends State<RefiApp> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize deep links asynchronously to avoid blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeepLinks();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Check initial link
      try {
        final initialLink = await _appLinks!.getInitialLink();
        if (initialLink != null) {
          _handleDeepLink(initialLink);
        }
      } catch (e) {
        debugPrint('❌ Error getting initial link: $e');
      }

      // Listen to link stream
      _linkSubscription = _appLinks!.uriLinkStream.listen(
        (uri) {
          debugPrint('🔗 Deep link received: $uri');
          _handleDeepLink(uri);
        },
        onError: (err) {
          debugPrint('❌ Deep link error: $err');
        },
      );
    } catch (e) {
      debugPrint('❌ Error initializing AppLinks: $e');
      // Continue without deep links - app should still work
    }
  }

  void _handleDeepLink(Uri uri) {
    try {
      // Safely access Supabase instance
      final supabase = Supabase.instance.client;

      // Handle OAuth deep link callback (refi://auth-callback)
      if (uri.scheme == 'refi' && uri.host == 'auth-callback') {
        supabase.auth.getSessionFromUrl(uri).then((_) {
          debugPrint('✅ OAuth session restored from deep link');
          // Optional: Navigate to home if not already there
        }).catchError((err) {
          debugPrint('❌ Error restoring session from deep link: $err');
        });
      }
      // Handle password reset deep link (refi://reset-password)
      else if (uri.scheme == 'refi' && uri.host == 'reset-password') {
        supabase.auth.getSessionFromUrl(uri).then((_) {
          debugPrint('✅ Password reset session restored from deep link');

          // Wait a brief moment to ensure session is set
          Future.delayed(const Duration(milliseconds: 500), () {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: di.sl<AuthCubit>(),
                    child: const UpdatePasswordScreen(),
                  ),
                ),
              );
            } else {
              debugPrint(
                  '❌ Navigator state is null, cannot navigate to UpdatePasswordScreen');
            }
          });
        }).catchError((err) {
          debugPrint('❌ Error restoring password reset session: $err');
        });
      }
      // Handle Supabase callback URLs (if redirected)
      else if (uri.toString().contains('supabase.co/auth/v1/callback')) {
        supabase.auth.getSessionFromUrl(uri).then((_) {
          debugPrint('✅ OAuth session restored from Supabase callback');
        }).catchError((err) {
          debugPrint('❌ Error restoring session from callback: $err');
        });
      }
    } catch (e) {
      debugPrint('❌ Error handling deep link: $e');
    }
  }

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
        // Use builder to wrap the entire app with BlocListener
        builder: (context, child) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                debugPrint(
                    '🛑 AuthUnauthenticated state received in main.dart listener');

                // 1. Reset Application State (Privacy)
                context.read<LibraryCubit>().reset();
                context.read<QuoteCubit>().reset();

                // 2. Clear navigation stack and go to login
                // Use scheduler binding to ensure we don't navigate during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                });
              }
            },
            child: child!,
          );
        },
        home: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return current is AuthAuthenticated ||
                current is AuthUnauthenticated ||
                current is AuthFirstTime;
          },
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const NetworkAwareWidget(
                child: MainNavigationScreen(),
              );
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
