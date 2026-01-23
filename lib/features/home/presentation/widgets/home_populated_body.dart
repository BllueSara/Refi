import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/scale_button.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../../domain/entities/home_entity.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/pages/book_details_page.dart';
import '../../../add_book/presentation/screens/search_screen.dart';
import 'book_card.dart';
import 'annual_goal_card.dart';
import 'home_stats_row.dart';
import '../cubit/home_cubit.dart';
import 'floating_book_illustration.dart';
import '../../../../core/widgets/gradient_slider_track_shape.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomePopulatedBody extends StatelessWidget {
  final HomeData data;

  const HomePopulatedBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Annual Goal Card (Hero)
            AnnualGoalCard(
              completedBooks: data.completedBooks,
              annualGoal: data.annualGoal,
              onSetGoal: () {
                _showGoalSettingSheet(context, data.annualGoal ?? 0);
              },
            ),

            const SizedBox(height: 32),

            // Stats Label
            Text(
              "إحصائياتك",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            HomeStatsRow(data: data),

            const SizedBox(height: 32),

            // Currently Reading Section
            if (data.currentlyReading.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const FloatingBookIllustration(),
                    const SizedBox(height: 16),
                    Text(
                      "لم تبدأ قراءة أي كتاب بعد",
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ScaleButton(
                      onTap: () {
                        // Navigate to Search Screen directly
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        ).then((_) {
                          // Refresh Home Data when back
                          if (context.mounted) {
                            context.read<HomeCubit>().loadHomeData();
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "أضف كتابك الأول",
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.currentlyReading,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textMain,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final mainNavState = context.findAncestorStateOfType<
                          State<MainNavigationScreen>>();
                      if (mainNavState != null && mainNavState.mounted) {
                        (mainNavState as dynamic)
                            .changeTab(1, libraryTab: AppStrings.tabReading);
                      }
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: GoogleFonts.tajawal(
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.currentlyReading.length,
                  itemBuilder: (context, index) {
                    final homeBook = data.currentlyReading[index];
                    return BookCard(
                      book: homeBook,
                      onTap: () async {
                        final libraryState = context.read<LibraryCubit>().state;
                        BookEntity? bookEntity;

                        if (libraryState is LibraryLoaded) {
                          try {
                            bookEntity = libraryState.books.firstWhere(
                              (book) =>
                                  book.title == homeBook.title &&
                                  book.author == homeBook.author,
                            );
                          } catch (e) {
                            // Not found
                          }
                        }

                        if (bookEntity != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookDetailsPage(book: bookEntity!),
                            ),
                          );
                          if (context.mounted) {
                            context.read<LibraryCubit>().loadLibrary();
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showGoalSettingSheet(BuildContext context, int currentGoal) {
    int selectedGoal = (currentGoal > 0) ? currentGoal : 24;
    final homeCubit = context.read<HomeCubit>();
    bool isSuccess = false; // Local state for view swapping

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isSuccess
                    ? _buildSuccessView(context, selectedGoal)
                    : Column(
                        key: const ValueKey('InputView'),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            "هدفك للقراءة في ${DateTime.now().year}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "كم كتاباً تتحدى نفسك لقراءته هذا العام؟",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppColors.textSub,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Big Number Display
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.refiMeshGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              "$selectedGoal",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                          Text(
                            "كتاب",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: AppColors.textSub,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryBlue,
                              inactiveTrackColor: AppColors.inputBorder,
                              trackShape: const GradientRectSliderTrackShape(
                                  gradient: AppColors.refiMeshGradient),
                              thumbColor: AppColors.primaryBlue,
                              overlayColor:
                                  AppColors.primaryBlue.withOpacity(0.1),
                              trackHeight:
                                  8, // Thicker track for better gradient visibility
                            ),
                            child: Slider(
                              value: selectedGoal.toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              label: selectedGoal.toString(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGoal = value.toInt();
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Save Button
                          ScaleButton(
                            onTap: () {
                              // 1. Instant Feedback
                              HapticFeedback.lightImpact();

                              // 2. Optimistic Update (Fire & Forget)
                              homeCubit.updateAnnualGoal(selectedGoal);

                              // 3. Switch UI Immediately
                              setState(() {
                                isSuccess = true;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.refiMeshGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "حفظ الهدف",
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSuccessView(BuildContext context, int goal) {
    return Column(
      key: const ValueKey('SuccessView'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        // Glowing Icon
        // Success Animation
        Lottie.asset(
          'assets/images/Success.json',
          width: 200,
          height: 200,
          repeat: false,
        ),
        const SizedBox(height: 8),
        Text(
          "تم تحديد هدفك بنجاح!",
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "رحلة الألف ميل تبدأ بكتاب واحد...",
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: AppColors.textSub,
          ),
        ),
        const SizedBox(height: 32),
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.inputBorder.withOpacity(0.3), // Light Grey
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "هدفك السنوي",
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$goal كتاباً في ${DateTime.now().year}",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Continue Button
        ScaleButton(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.refiMeshGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "فلنبدأ القراءة ←",
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
