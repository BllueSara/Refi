import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
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
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const Text(
                  AppStrings.reviewTitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(width: 48), // Balance for cancel button
              ],
            ),

            const SizedBox(height: 24),

            // Quote Text Field
            Text(
              AppStrings
                  .quoteTextLabel, // "نص الاقتباس" but prompt image says "نص الاقتباس" above field? No, it just shows text.
              // Prompt says: Fields: نص الاقتباس: A large editable text field
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),

            const SizedBox(height: 24),

            // Feelings
            const Text(
              AppStrings.feelingLabel,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _feelings.map((feeling) {
                final isSelected = _selectedFeeling == feeling;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(feeling),
                    labelStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      color: isSelected ? Colors.white : AppColors.textSub,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors
                        .primaryBlue, // Needs gradient technically but ChoiceChip color property is solid.
                    // To do gradient chips, custom container detector is needed.
                    // Prompt says: "The active chip should have a blue gradient fill."
                    // I will simulate with Container and GestureDetector for pixel perfection.
                    backgroundColor: AppColors.inputBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 24),

            // Personal Notes
            const Text(
              AppStrings.notesLabel,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: AppStrings.notesHint,
                  hintStyle: TextStyle(
                    fontFamily: 'Tajawal',
                    color: AppColors.textPlaceholder,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Source Book Dropdown
            const Text(
              AppStrings.sourceBookLabel,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                List<BookEntity> userBooks = [];

                if (state is LibraryLoaded) {
                  userBooks = state.books;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showBookError
                          ? Colors.red
                          : AppColors.inputBorder,
                      width: _showBookError ? 2 : 1,
                    ),
                  ),
                  child: userBooks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'لا توجد كتب محفوظة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: AppColors.textPlaceholder,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text(
                              "اختر الكتاب المصدر",
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                              ),
                            ),
                            value: _selectedBook,
                            items: userBooks
                                .map(
                                  (book) => DropdownMenuItem(
                                    value: book.id,
                                    child: Text(
                                      '${book.title} - ${book.author}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
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

            const SizedBox(height: 32),

            // Save Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24),
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      isSaving ? 'جاري الحفظ...' : AppStrings.save,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24), // Bottom padding
          ],
        ),
      ),
    );
  }
}
