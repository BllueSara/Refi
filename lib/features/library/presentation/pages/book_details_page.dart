import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../cubit/book_details/book_details_cubit.dart';
import '../cubit/book_details/book_details_state.dart';
import '../widgets/book_metadata.dart';
import '../widgets/progress_card.dart';

class BookDetailsPage extends StatelessWidget {
  final String bookTitle;
  final String author;
  final int currentPage;
  final int totalPages;
  final List<String> tags;

  const BookDetailsPage({
    super.key,
    required this.bookTitle,
    required this.author,
    this.currentPage = 0,
    this.totalPages = 0,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookDetailsCubit(currentPage: currentPage, totalPages: totalPages),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: AppColors.textMain),
            ),
          ],
          title: Text(
            AppStrings.detailsTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 20),
          ),
        ),
        body: BlocBuilder<BookDetailsCubit, BookDetailsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // Cover
                  Container(
                    width: 140,
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      // Placeholder color/image
                      color: const Color(0xFFA8C6CB),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Title & Author
                  Text(
                    bookTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textSub),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Metadata (Tags)
                  BookMetadata(tags: tags),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Progress
                  ProgressCard(
                    state: state,
                    onUpdatePressed: () => _showUpdateDialog(context),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Quotes List Section
                  _buildQuotesSection(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuotesSection(BuildContext context, BookDetailsState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.quotesSectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                AppStrings.viewAll,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),

        if (state.quotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 48,
                  color: AppColors.textPlaceholder.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noQuotesTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.noQuotesBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          // ... Build list if needed (Placeholder for now as logic implies empty starts)
          const SizedBox(),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context) {
    // We need to capture the Cubit before pushing the dialog context
    final cubit = context.read<BookDetailsCubit>();
    final controller = TextEditingController(
      text: cubit.state.currentPage.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inactiveDot,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "تحديث القراءة",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: "رقم الصفحة الحالية",
                hintText: "مثال: 50",
                suffixText: "من ${cubit.state.totalPages}",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final val = int.tryParse(controller.text);
                  if (val != null) {
                    cubit.updateProgress(val);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "حفظ التقدم",
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
