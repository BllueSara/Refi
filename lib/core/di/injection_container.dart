import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/signin_with_google_usecase.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/library/data/datasources/book_remote_data_source.dart';
import '../../features/library/data/repositories/book_repository_impl.dart';
import '../../features/library/domain/repositories/book_repository.dart';
import '../../features/library/domain/usecases/add_book_to_library_usecase.dart';
import '../../features/library/domain/usecases/fetch_user_library_usecase.dart';
import '../../features/library/domain/usecases/search_books_usecase.dart';
import '../../features/library/domain/usecases/update_book_usecase.dart';
import '../../features/library/domain/usecases/delete_book_usecase.dart';
import '../../features/library/presentation/cubit/library_cubit.dart';
import '../../features/library/presentation/cubit/search_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/scanner/data/datasources/ocr_service.dart';
import '../../features/scanner/data/repositories/ocr_repository_impl.dart';
import '../../features/scanner/domain/repositories/ocr_repository.dart';
import '../../features/scanner/domain/usecases/scan_text_usecase.dart';
import '../../features/scanner/presentation/cubit/scanner_cubit.dart';
import '../../core/services/image_picker_service.dart';

import '../../features/quotes/data/datasources/quote_remote_data_source.dart';
import '../../features/quotes/data/repositories/quote_repository_impl.dart';
import '../../features/quotes/domain/repositories/quote_repository.dart';
import '../../features/quotes/domain/usecases/save_quote_usecase.dart';
import '../../features/quotes/domain/usecases/get_user_quotes_usecase.dart';
import '../../features/quotes/domain/usecases/get_book_quotes_usecase.dart';
import '../../features/quotes/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/quotes/presentation/cubit/quote_cubit.dart';

final sl = GetIt.instance;

Future<void> init(SharedPreferences sharedPreferences) async {
  // Reset GetIt to prevent duplicate registration on hot restart
  await sl.reset();

  // ! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      resetPasswordUseCase: sl(),
      updatePasswordUseCase: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ! Features - Library
  // Bloc
  sl.registerFactory(
    () => LibraryCubit(
      fetchUserLibraryUseCase: sl(),
      addBookToLibraryUseCase: sl(),
      deleteBookUseCase: sl(),
      updateBookUseCase: sl(),
    ),
  );
  sl.registerFactory(() => SearchCubit(searchBooksUseCase: sl()));

  // ! Features - Profile
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      supabaseClient: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SearchBooksUseCase(sl()));
  sl.registerLazySingleton(() => AddBookToLibraryUseCase(sl()));
  sl.registerLazySingleton(() => FetchUserLibraryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBookUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(supabaseClient: sl(), client: sl()),
  );

  // ! Features - Profile
  // Remote Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Case
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // ! Features - Scanner
  sl.registerFactory(
    () => ScannerCubit(scanTextUseCase: sl(), imagePickerService: sl()),
  );
  sl.registerLazySingleton(() => ScanTextUseCase(sl()));
  sl.registerLazySingleton<OCRRepository>(
    () => OCRRepositoryImpl(ocrService: sl()),
  );
  sl.registerLazySingleton<OCRService>(() => OCRServiceImpl());

  // ! Features - Quotes
  sl.registerFactory(
    () => QuoteCubit(
      saveQuoteUseCase: sl(),
      getUserQuotesUseCase: sl(),
      getBookQuotesUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => SaveQuoteUseCase(sl()));
  sl.registerLazySingleton(() => GetUserQuotesUseCase(sl()));
  sl.registerLazySingleton(() => GetBookQuotesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton<QuoteRepository>(
    () => QuoteRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<QuoteRemoteDataSource>(
    () => QuoteRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ! Services
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());

  // ! External
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => sharedPreferences);
}
