import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/domain/entities/book_entity.dart';
import 'section_header.dart';

class BookDropdownSection extends StatelessWidget {
  final String? selectedBook;
  final bool showError;
  final Function(String?) onBookSelected;

  const BookDropdownSection({
    super.key,
    required this.selectedBook,
    required this.showError,
    required this.onBookSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: AppStrings.sourceBookLabel,
          icon: Icons.book_rounded,
        ),
        SizedBox(height: 12.h(context)),
        BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            List<BookEntity> userBooks = [];

            if (state is LibraryLoaded) {
              userBooks = state.books;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: 18.w(context),
                vertical: 4.h(context),
              ),
              decoration: BoxDecoration(
                color: showError
                    ? AppColors.errorRed.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r(context)),
                border: Border.all(
                  color: showError ? AppColors.errorRed : AppColors.inputBorder,
                  width: showError ? 2 : 1.5,
                ),
              ),
              child: userBooks.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h(context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            color: AppColors.textPlaceholder,
                            size: 20.sp(context),
                          ),
                          SizedBox(width: 8.w(context)),
                          Text(
                            'لا توجد كتب محفوظة',
                            style: TextStyle(
                              color: AppColors.textPlaceholder,
                              fontSize: 14.sp(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSub,
                          size: 24.sp(context),
                        ),
                        hint: Row(
                          children: [
                            Container(
                              width: 32.w(context),
                              height: 48.h(context),
                              decoration: BoxDecoration(
                                color: AppColors.inputBorder,
                                borderRadius:
                                    BorderRadius.circular(6.r(context)),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: AppColors.textPlaceholder,
                                size: 18.sp(context),
                              ),
                            ),
                            SizedBox(width: 12.w(context)),
                            Text(
                              "اختر الكتاب المصدر",
                              style: TextStyle(
                                fontSize: 14.sp(context),
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ],
                        ),
                        value: selectedBook,
                        selectedItemBuilder: (context) {
                          return userBooks.map((book) {
                            return Row(
                              children: [
                                Container(
                                  width: 32.w(context),
                                  height: 48.h(context),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(6.r(context)),
                                    color: AppColors.inputBorder,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4.r(context),
                                        offset: Offset(0, 2.h(context)),
                                      ),
                                    ],
                                  ),
                                  child: (book.imageUrl != null &&
                                          book.imageUrl!.isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              6.r(context)),
                                          child: Image.network(
                                            book.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.book_rounded,
                                                color: AppColors.primaryBlue,
                                                size: 18.sp(context),
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.book_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 18.sp(context),
                                        ),
                                ),
                                SizedBox(width: 12.w(context)),
                                Expanded(
                                  child: Text(
                                    '${book.title} - ${book.author}',
                                    style: TextStyle(
                                      fontSize: 14.sp(context),
                                      color: AppColors.textMain,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                        items: userBooks
                            .map(
                              (book) => DropdownMenuItem(
                                value: book.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32.w(context),
                                      height: 48.h(context),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.r(context)),
                                        color: AppColors.inputBorder,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4.r(context),
                                            offset: Offset(0, 2.h(context)),
                                          ),
                                        ],
                                      ),
                                      child: (book.imageUrl != null &&
                                              book.imageUrl!.isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6.r(context)),
                                              child: Image.network(
                                                book.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Icon(
                                                      Icons.book_rounded,
                                                      color:
                                                          AppColors.primaryBlue,
                                                      size: 18.sp(context),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.book_rounded,
                                                color: AppColors.primaryBlue,
                                                size: 18.sp(context),
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: 12.w(context)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            book.title,
                                            style: TextStyle(
                                              fontSize: 15.sp(context),
                                              color: AppColors.textMain,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 3.h(context)),
                                          Text(
                                            book.author,
                                            style: TextStyle(
                                              fontSize: 13.sp(context),
                                              color: AppColors.textSub,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onBookSelected,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
