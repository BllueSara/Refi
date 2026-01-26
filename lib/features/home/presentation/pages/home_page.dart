import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/home_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_empty_body.dart';
import '../widgets/home_populated_body.dart';
import '../widgets/home_skeleton.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../library/domain/usecases/fetch_user_library_usecase.dart';
import '../../../quotes/domain/usecases/get_user_quotes_usecase.dart';
import '../../../library/presentation/cubit/library_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _lastCompletedBooks;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        getProfileUseCase: di.sl<GetProfileUseCase>(),
        fetchUserLibraryUseCase: di.sl<FetchUserLibraryUseCase>(),
        getUserQuotesUseCase: di.sl<GetUserQuotesUseCase>(),
        supabaseClient: di.sl<SupabaseClient>(),
      )..loadHomeData(),
      child: BlocListener<LibraryCubit, LibraryState>(
        listener: (context, libraryState) {
          // When library is updated (book added/updated), refresh home data
          if (libraryState is LibraryLoaded || libraryState is LibraryEmpty) {
            context.read<HomeCubit>().loadHomeData();
          }
        },
        child: BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded) {
              // Check for book completion
              if (_lastCompletedBooks != null &&
                  state.data.completedBooks > _lastCompletedBooks!) {
                final annualGoal = state.data.annualGoal ?? 0;
                // Check if they just hit the annual goal
                if (annualGoal > 0 &&
                    state.data.completedBooks >= annualGoal &&
                    _lastCompletedBooks! < annualGoal) {
                  _showCelebrationSheet(
                    context,
                    title: "إنجاز عظيم!",
                    message: "لقد أتممت هدفك السنوي للقراءة بنجاح!",
                  );
                } else {
                  // Regular book completion
                  _showCelebrationSheet(
                    context,
                    title: "تهانينا!",
                    message: "لقد وسمت كتاباً جديداً كمكتمل.",
                  );
                }
              }
              _lastCompletedBooks = state.data.completedBooks;
            } else if (state is HomeEmpty) {
              _lastCompletedBooks = state.data.completedBooks;
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              HomeData? currentData;
              if (state is HomeLoaded) {
                currentData = state.data;
              } else if (state is HomeEmpty) {
                currentData = state.data;
              } else {
                currentData = const HomeData(
                  username: "...",
                  streakDays: 0,
                  completedBooks: 0,
                  totalQuotes: 0,
                  topTag: "",
                );
              }

              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: HomeHeader(data: currentData),
                body: RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<HomeCubit>()
                        .loadHomeData(forceRefresh: true);
                  },
                  color: AppColors.primaryBlue,
                  child: Builder(
                    builder: (context) {
                      if (state is HomeLoading) {
                        return const HomeSkeleton();
                      } else if (state is HomeEmpty) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height - 150),
                            child: HomeEmptyBody(data: state.data),
                          ),
                        );
                      } else if (state is HomeLoaded) {
                        return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: HomePopulatedBody(data: state.data));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCelebrationSheet(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r(context))),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(24.w(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h(context)),
              Lottie.asset(
                'assets/images/Success.json',
                width: 200.w(context),
                height: 200.h(context),
                repeat: false,
              ),
              SizedBox(height: 8.h(context)),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 24.sp(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 8.h(context)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 16.sp(context),
                  color: AppColors.textSub,
                ),
              ),
              SizedBox(height: 32.h(context)),
              // Continue Button
              Container(
                width: double.infinity,
                height: 56.h(context),
                decoration: BoxDecoration(
                  gradient: AppColors.refiMeshGradient,
                  borderRadius: BorderRadius.circular(16.r(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 10.r(context),
                      offset: Offset(0, 4.h(context)),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(16.r(context)),
                    child: Center(
                      child: Text(
                        "رائع",
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp(context),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h(context)),
            ],
          ),
        );
      },
    );
  }
}
