import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/update_book_usecase.dart';
import '../cubit/book_details/book_details_cubit.dart';
import '../cubit/book_details/book_details_state.dart';
import '../widgets/progress_card.dart';
import '../widgets/book_status_selector.dart';
import '../../../../core/widgets/refi_buttons.dart';
import '../../../quotes/domain/usecases/get_book_quotes_usecase.dart';
import '../cubit/library_cubit.dart';
import '../../../add_book/presentation/screens/manual_entry_screen.dart';

class BookDetailsPage extends StatelessWidget {
  final BookEntity book;

  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookDetailsCubit(
        book: book,
        updateBookUseCase: di.sl<UpdateBookUseCase>(),
        getBookQuotesUseCase: di.sl<GetBookQuotesUseCase>(),
        libraryCubit: context.read<LibraryCubit>(),
      ),
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
            _buildPopupMenu(context),
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
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      // Fallback color if image fails or doesn't exist
                      color: const Color(0xFFA8C6CB),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                        ? Image.network(
                            book.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.book,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Title & Author
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textSub),
                  ),

                  // Status Chips Selection (Simple View)
                  const SizedBox(height: AppDimensions.paddingM),
                  BookStatusSelector(
                    currentStatus: state.status,
                    onStatusChanged: (s) =>
                        context.read<BookDetailsCubit>().changeStatus(s),
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Progress (Only if reading or completed)
                  if (state.status == BookStatus.reading ||
                      state.status == BookStatus.completed)
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.quotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quote = state.quotes[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.text,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    if (quote.notes != null && quote.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        quote.notes!,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quote.feeling,
                            style: const TextStyle(
                              //fontFamily: 'Tajawal',
                              fontSize: 10,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
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
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return Container(
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
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: "رقم الصفحة الحالية",
                    hintText: "مثال: 50",
                    suffixText: "من ${cubit.state.totalPages}",
                    // Error Styles
                    errorStyle: const TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD32F2F),
                    ),
                    errorMaxLines: 2,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFD32F2F), width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFD32F2F), width: 1.5),
                    ),
                    // Normal Styles
                    filled: true,
                    fillColor: AppColors.inputBorder.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "يرجى إدخال رقم الصفحة";
                    }
                    final current = int.tryParse(val);
                    if (current == null) {
                      return "يرجى إدخال رقم الصفحة بشكل صحيح";
                    }
                    if (current < 0) {
                      return "لا يمكن أن يكون الرقم سالباً";
                    }
                    if (current > cubit.state.totalPages) {
                      return "لا يمكن أن يكون رقم الصفحة أكبر من إجمالي صفحات الكتاب (${cubit.state.totalPages} صفحة)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                RefiButton(
                  label: "حفظ التقدم",
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      final val = int.tryParse(controller.text);
                      if (val != null) {
                        cubit.updateProgress(val);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    // Strict Contextual Menu Logic
    final bool isManualBook = book.source == 'manual';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textMain),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManualEntryScreen(book: book),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<LibraryCubit>().loadLibrary(forceRefresh: true);
            }
          });
        } else if (value == 'delete') {
          _showDeleteConfirmation(context);
        }
      },
      itemBuilder: (popupCtx) {
        // Strict Logic:
        // Manual Source -> Show Edit & Delete
        // Google/Other -> Show Only Delete
        if (isManualBook) {
          return [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.textMain),
                  const SizedBox(width: 12),
                  Text(
                    "تعديل معلومات الكتاب",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    "حذف الكتاب",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ];
        }

        // For Google/API books - Delete ONLY
        return [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  "حذف الكتاب",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "هل أنت متأكد من حذف هذا الكتاب من مكتبتك؟",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          "إلغاء",
                          style: GoogleFonts.tajawal(
                            color: AppColors.textSub,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Perform delete through LibraryCubit
                            context.read<LibraryCubit>().deleteBook(book.id);
                            Navigator.pop(dialogCtx); // Close dialog
                            Navigator.pop(context); // Close details page
                          },
                          child: Text(
                            "حذف",
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
