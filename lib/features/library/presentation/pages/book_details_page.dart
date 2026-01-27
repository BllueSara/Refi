import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
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
            icon: Icon(Icons.arrow_back_ios,
                color: AppColors.textMain, size: 20.sp(context)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            _buildPopupMenu(context),
          ],
          title: Text(
            AppStrings.detailsTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 20.sp(context)),
          ),
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, libraryState) {
            BookEntity updatedBook;
            if (libraryState is LibraryLoaded) {
              try {
                final foundBook = libraryState.books.firstWhere(
                  (b) => b.id == book.id,
                );
                updatedBook = BookEntity(
                  id: foundBook.id,
                  title: foundBook.title,
                  authors: foundBook.authors,
                  imageUrl: foundBook.imageUrl,
                  rating: foundBook.rating,
                  description: foundBook.description,
                  publishedDate: foundBook.publishedDate,
                  pageCount: foundBook.pageCount,
                  status: foundBook.status,
                  currentPage: foundBook.currentPage,
                  categories: foundBook.categories,
                  googleBookId: foundBook.googleBookId,
                  source: foundBook.source,
                );
              } catch (_) {
                updatedBook = book;
              }
            } else {
              updatedBook = book;
            }

            return BlocBuilder<BookDetailsCubit, BookDetailsState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.paddingL.w(context)),
                  child: Column(
                    children: [
                      // Cover
                      Container(
                        width: 140.w(context),
                        height: 210.h(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20.r(context),
                              offset: Offset(0, 10.h(context)),
                            ),
                          ],
                          color: const Color(0xFFA8C6CB),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (updatedBook.imageUrl != null &&
                                updatedBook.imageUrl!.isNotEmpty)
                            ? Image.network(
                                updatedBook.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.book,
                                      size: 48.sp(context),
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.book,
                                  size: 48.sp(context),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                      ),
                      SizedBox(height: AppDimensions.paddingL.h(context)),

                      // Title & Author
                      Text(
                        updatedBook.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 24.sp(context)),
                      ),
                      SizedBox(height: 8.h(context)),
                      Text(
                        updatedBook.author,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.textSub),
                      ),

                      // Status Chips Selection (Simple View)
                      SizedBox(height: AppDimensions.paddingM.h(context)),
                      BookStatusSelector(
                        currentStatus: state.status,
                        onStatusChanged: (s) =>
                            context.read<BookDetailsCubit>().changeStatus(s),
                      ),

                      SizedBox(height: AppDimensions.paddingL.h(context)),

                      // Progress (Only if reading or completed)
                      if (state.status == BookStatus.reading ||
                          state.status == BookStatus.completed)
                        ProgressCard(
                          state: state,
                          onUpdatePressed: () => _showUpdateDialog(context),
                        ),

                      SizedBox(height: AppDimensions.paddingXL.h(context)),

                      // Quotes List Section
                      _buildQuotesSection(context, state),
                    ],
                  ),
                );
              },
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
        SizedBox(height: AppDimensions.paddingM.h(context)),
        if (state.quotes.isEmpty)
          Container(
            padding: EdgeInsets.all(32.w(context)),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24.r(context)),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 48.sp(context),
                  color: AppColors.textPlaceholder.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h(context)),
                Text(
                  AppStrings.noQuotesTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h(context)),
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
            separatorBuilder: (context, index) =>
                SizedBox(height: 12.h(context)),
            itemBuilder: (context, index) {
              final quote = state.quotes[index];
              return Container(
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.r(context)),
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
                        fontSize: 14.sp(context),
                        height: 1.6,
                      ),
                    ),
                    if (quote.notes != null && quote.notes!.isNotEmpty) ...[
                      SizedBox(height: 8.h(context)),
                      Text(
                        quote.notes!,
                        style: GoogleFonts.tajawal(
                          fontSize: 12.sp(context),
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w(context),
                            vertical: 4.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r(context)),
                          ),
                          child: Text(
                            quote.feeling,
                            style: TextStyle(
                              //fontFamily: 'Tajawal',
                              fontSize: 10.sp(context),
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h(ctx),
            left: 24.w(ctx),
            right: 24.w(ctx),
            top: 24.h(ctx),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24.r(ctx))),
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
                    width: 40.w(ctx),
                    height: 4.h(ctx),
                    decoration: BoxDecoration(
                      color: AppColors.inactiveDot,
                      borderRadius: BorderRadius.circular(2.r(ctx)),
                    ),
                  ),
                ),
                SizedBox(height: 24.h(ctx)),
                Text(
                  "تحديث القراءة",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16.h(ctx)),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 18.sp(ctx),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: "رقم الصفحة الحالية",
                    hintText: "مثال: 50",
                    suffixText: "من ${cubit.state.totalPages}",
                    // Error Styles
                    errorStyle: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 12.sp(ctx),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD32F2F),
                    ),
                    errorMaxLines: 2,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r(ctx)),
                      borderSide:
                          const BorderSide(color: Color(0xFFD32F2F), width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r(ctx)),
                      borderSide: const BorderSide(
                          color: Color(0xFFD32F2F), width: 1.5),
                    ),
                    // Normal Styles
                    filled: true,
                    fillColor: AppColors.inputBorder.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r(ctx)),
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
                SizedBox(height: 24.h(ctx)),
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
    // Show edit option only if book was added manually by user
    // Books from API (google) should not have edit option
    final bool isManualBook = book.source == 'manual' ||
        (book.source == null && book.googleBookId == null);

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: AppColors.textMain, size: 24.sp(context)),
      offset: Offset(0, 50.h(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r(context)),
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
                  Icon(Icons.edit_outlined,
                      size: 20.sp(context), color: AppColors.textMain),
                  SizedBox(width: 12.w(context)),
                  Text(
                    "تعديل معلومات الكتاب",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp(context),
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
                  Icon(Icons.delete_outline,
                      size: 20.sp(context), color: Colors.red),
                  SizedBox(width: 12.w(context)),
                  Text(
                    "حذف الكتاب",
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp(context),
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
                Icon(Icons.delete_outline,
                    size: 20.sp(context), color: Colors.red),
                SizedBox(width: 12.w(context)),
                Text(
                  "حذف الكتاب",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp(context),
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
            padding: EdgeInsets.all(24.w(context)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r(context)),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w(context)),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 32.sp(context),
                  ),
                ),
                SizedBox(height: 24.h(context)),
                Text(
                  "هل أنت متأكد من حذف هذا الكتاب من مكتبتك؟",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp(context),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h(context)),
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
                            fontSize: 14.sp(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w(context)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16.r(context)),
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
                              fontSize: 14.sp(context),
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
