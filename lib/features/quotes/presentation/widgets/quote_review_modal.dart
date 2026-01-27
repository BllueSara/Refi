import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/quote_cubit.dart';
import 'quote_review_header.dart';
import 'quote_text_field_section.dart';
import 'feelings_selector_section.dart';
import 'notes_field_section.dart';
import 'book_dropdown_section.dart';
import 'save_quote_button.dart';

class QuoteReviewModal extends StatefulWidget {
  final String initialText;
  const QuoteReviewModal({super.key, this.initialText = ""});

  @override
  State<QuoteReviewModal> createState() => _QuoteReviewModalState();
}

class _QuoteReviewModalState extends State<QuoteReviewModal>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  String? _selectedFeeling;
  bool _showBookError = false;
  String? _selectedBook;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialText.isNotEmpty ? widget.initialText : "",
    );
    _notesController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20.sp(context),
              ),
              SizedBox(width: 12.w(context)),
              const Text('الرجاء إدخال نص الاقتباس'),
            ],
          ),
          backgroundColor: AppColors.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
        ),
      );
      return;
    }

    if (_selectedBook == null) {
      setState(() => _showBookError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20.sp(context),
              ),
              SizedBox(width: 12.w(context)),
              const Text('الرجاء اختيار الكتاب'),
            ],
          ),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r(context)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r(context),
              offset: Offset(0, -5.h(context)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: EdgeInsets.only(top: 12.h(context)),
              width: 48.w(context),
              height: 5.h(context),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3.r(context)),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // Header
            QuoteReviewHeader(
              onCancel: () => Navigator.pop(context),
            ),

            SizedBox(height: 28.h(context)),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quote Text Field Section
                    QuoteTextFieldSection(
                      controller: _textController,
                    ),

                    SizedBox(height: 28.h(context)),

                    // Feelings Section
                    FeelingsSelectorSection(
                      selectedFeeling: _selectedFeeling,
                      onFeelingSelected: (feeling) {
                        setState(() => _selectedFeeling = feeling);
                      },
                    ),

                    SizedBox(height: 28.h(context)),

                    // Personal Notes Section
                    NotesFieldSection(
                      controller: _notesController,
                    ),

                    SizedBox(height: 28.h(context)),

                    // Source Book Dropdown Section
                    BookDropdownSection(
                      selectedBook: _selectedBook,
                      showError: _showBookError,
                      onBookSelected: (val) {
                        setState(() {
                          _selectedBook = val;
                          _showBookError = false;
                        });
                      },
                    ),

                    SizedBox(height: 32.h(context)),

                    // Save Button
                    BlocConsumer<QuoteCubit, QuoteState>(
                      listener: (context, state) {
                        if (state is QuoteSaved) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20.sp(context),
                                  ),
                                  SizedBox(width: 12.w(context)),
                                  const Text('تم حفظ الاقتباس بنجاح'),
                                ],
                              ),
                              backgroundColor: AppColors.successGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.r(context)),
                              ),
                            ),
                          );
                          context.read<QuoteCubit>().loadUserQuotes();
                        } else if (state is QuoteError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 20.sp(context),
                                  ),
                                  SizedBox(width: 12.w(context)),
                                  Text(state.message),
                                ],
                              ),
                              backgroundColor: AppColors.errorRed,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12.r(context)),
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isSaving = state is QuoteSaving;
                        return SaveQuoteButton(
                          onSave: _handleSave,
                          isSaving: isSaving,
                        );
                      },
                    ),
                    SizedBox(height: 24.h(context)), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
