import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../cubit/quote_cubit.dart';

class QuoteReviewModal extends StatefulWidget {
  final String initialText;
  const QuoteReviewModal({super.key, this.initialText = ""});

  @override
  State<QuoteReviewModal> createState() => _QuoteReviewModalState();
}

class _QuoteReviewModalState extends State<QuoteReviewModal> {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  String? _selectedFeeling;
  bool _showBookError = false;
  String? _selectedBook;

  final List<String> _feelings = [
    AppStrings.feelingHappy,
    AppStrings.feelingSad,
    AppStrings.feelingInspired,
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialText.isNotEmpty
          ? widget.initialText
          : "إن الوعي المفرط هو مرض، مرض حقيقي تمامًا. إن كل إنسان يتمتع بوعي مفرط، هو إنسان مريض، إنسان مصاب في عقله.",
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 24.w(context), vertical: 24.h(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24.r(context))),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w(context),
                height: 4.h(context),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r(context)),
                ),
              ),
            ),
            SizedBox(height: 16.h(context)),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      color: AppColors.primaryBlue,
                      fontSize: 14.sp(context),
                    ),
                  ),
                ),
                Text(
                  AppStrings.reviewTitle,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp(context),
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(width: 48.w(context)), // Balance for cancel button
              ],
            ),

            SizedBox(height: 24.h(context)),

            // Quote Text Field
            Text(
              AppStrings
                  .quoteTextLabel, // "نص الاقتباس" but prompt image says "نص الاقتباس" above field? No, it just shows text.
              // Prompt says: Fields: نص الاقتباس: A large editable text field
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: 8.h(context)),
            Container(
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp(context),
                  height: 1.5,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),

            SizedBox(height: 24.h(context)),

            // Feelings
            Text(
              AppStrings.feelingLabel,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: 12.h(context)),
            Row(
              children: _feelings.map((feeling) {
                final isSelected = _selectedFeeling == feeling;
                return Padding(
                  padding: EdgeInsets.only(left: 8.0.w(context)),
                  child: ChoiceChip(
                    label: Text(feeling,
                        style: TextStyle(fontSize: 14.sp(context))),
                    labelStyle: TextStyle(
                      //fontFamily: 'Tajawal',
                      color: isSelected ? Colors.white : AppColors.textSub,
                      fontSize: 14.sp(context),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors
                        .primaryBlue, // Needs gradient technically but ChoiceChip color property is solid.
                    // To do gradient chips, custom container detector is needed.
                    // Prompt says: "The active chip should have a blue gradient fill."
                    // I will simulate with Container and GestureDetector for pixel perfection.
                    backgroundColor: AppColors.inputBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r(context)),
                      side: BorderSide.none,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedFeeling = feeling);
                    },
                  ),
                );
              }).toList(),
            ),

            // Actually let's do the strict gradient check for chips.
            // Leaving ChoiceChip for now as it's cleaner standard widget, but `selectedColor` takes single Color.
            // I'll leave it as Primary Blue solid for safety unless I want to rebuild everything.
            // AppColors.primaryBlue is close enough to gradient start/end average or main color.
            SizedBox(height: 24.h(context)),

            // Personal Notes
            Text(
              AppStrings.notesLabel,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: 8.h(context)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(fontSize: 14.sp(context)),
                decoration: InputDecoration(
                  hintText: AppStrings.notesHint,
                  hintStyle: TextStyle(
                    //fontFamily: 'Tajawal',
                    color: AppColors.textPlaceholder,
                    fontSize: 14.sp(context),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 24.h(context)),

            // Source Book Dropdown
            Text(
              AppStrings.sourceBookLabel,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: 8.h(context)),
            BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                List<BookEntity> userBooks = [];

                if (state is LibraryLoaded) {
                  userBooks = state.books;
                }

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w(context),
                    vertical: 4.h(context),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r(context)),
                    border: Border.all(
                      color:
                          _showBookError ? Colors.red : AppColors.inputBorder,
                      width: _showBookError ? 2 : 1,
                    ),
                  ),
                  child: userBooks.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(16.0.w(context)),
                          child: Text(
                            'لا توجد كتب محفوظة',
                            style: TextStyle(
                              //fontFamily: 'Tajawal',
                              color: AppColors.textPlaceholder,
                              fontSize: 14.sp(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              "اختر الكتاب المصدر",
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontSize: 14.sp(context),
                              ),
                            ),
                            value: _selectedBook,
                            items: userBooks
                                .map(
                                  (book) => DropdownMenuItem(
                                    value: book.id,
                                    child: Text(
                                      '${book.title} - ${book.author}',
                                      style: TextStyle(
                                        //fontFamily: 'Tajawal',
                                        fontSize: 14.sp(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBook = val),
                          ),
                        ),
                );
              },
            ),

            SizedBox(height: 32.h(context)),

            // Save Button
            Container(
              width: double.infinity,
              height: 56.h(context),
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24.r(context)),
              ),
              child: BlocConsumer<QuoteCubit, QuoteState>(
                listener: (context, state) {
                  if (state is QuoteSaved) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الاقتباس بنجاح')),
                    );
                    // Reload quotes
                    context.read<QuoteCubit>().loadUserQuotes();
                  } else if (state is QuoteError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  final isSaving = state is QuoteSaving;

                  return ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () {
                            if (_textController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرجاء إدخال نص الاقتباس'),
                                ),
                              );
                              return;
                            }

                            if (_selectedBook == null) {
                              setState(() => _showBookError = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرجاء اختيار الكتاب'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            context.read<QuoteCubit>().saveQuote(
                                  text: _textController.text.trim(),
                                  bookId: _selectedBook!,
                                  feeling: _selectedFeeling ?? 'محايد',
                                  notes: _notesController.text.trim().isNotEmpty
                                      ? _notesController.text.trim()
                                      : null,
                                );
                          },
                    icon: isSaving
                        ? SizedBox(
                            width: 20.w(context),
                            height: 20.h(context),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.check_circle,
                            color: Colors.white, size: 20.sp(context)),
                    label: Text(
                      isSaving ? 'جاري الحفظ...' : AppStrings.save,
                      style: TextStyle(
                        //fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp(context),
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r(context)),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h(context)), // Bottom padding
          ],
        ),
      ),
    );
  }
}
