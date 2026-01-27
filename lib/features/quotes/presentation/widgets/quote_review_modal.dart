import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/refi_success_widget.dart';
import '../cubit/quote_cubit.dart';
import '../../domain/entities/quote_entity.dart';
import 'quote_review_header.dart';
import 'quote_text_field_section.dart';
import 'feelings_selector_section.dart';
import 'notes_field_section.dart';
import 'book_dropdown_section.dart';
import 'save_quote_button.dart';

class QuoteReviewModal extends StatefulWidget {
  final String initialText;
  final QuoteEntity? quote; // For editing existing quote

  const QuoteReviewModal({
    super.key,
    this.initialText = "",
    this.quote,
  });

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
      text: widget.quote?.text ??
          (widget.initialText.isNotEmpty ? widget.initialText : ""),
    );
    _notesController = TextEditingController(
      text: widget.quote?.notes ?? "",
    );
    _selectedFeeling = widget.quote?.feeling;
    _selectedBook = widget.quote?.bookId;
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

  Future<void> _handleSave() async {
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

    if (_selectedBook == null && widget.quote == null) {
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

    // Use existing bookId if editing, otherwise use selected book
    final bookId = widget.quote?.bookId ?? _selectedBook;

    // If editing, delete old quote first, then create new one
    if (widget.quote != null) {
      // Delete old quote first
      await context.read<QuoteCubit>().deleteQuote(widget.quote!.id);
    }

    // Create new quote
    context.read<QuoteCubit>().saveQuote(
          text: _textController.text.trim(),
          bookId: bookId,
          feeling: _selectedFeeling ?? widget.quote?.feeling ?? 'محايد',
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          isFavorite: widget.quote?.isFavorite ?? false,
        );
  }

  void _showSuccessScreen(BuildContext context) {
    HapticFeedback.heavyImpact();
    final isEdit = widget.quote != null;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => RefiSuccessWidget(
          title: isEdit ? "تم تحديث الاقتباس بنجاح!" : "تم حفظ الاقتباس بنجاح!",
          subtitle: isEdit
              ? "تم حفظ التعديلات الجديدة في اقتباساتك"
              : "أصبح الاقتباس الآن جزءاً من رحلتك المعرفية المثرية",
          primaryButtonLabel: "العودة للاقتباسات",
          onPrimaryAction: () {
            Navigator.of(ctx).pop();
          },
          secondaryButtonLabel: "إضافة اقتباس آخر",
          onSecondaryAction: () {
            Navigator.of(ctx).pop();
            // Show modal again for new quote
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const QuoteReviewModal(),
            );
          },
        ),
      ),
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
                          Navigator.pop(context); // Close modal
                          _showSuccessScreen(context);
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
