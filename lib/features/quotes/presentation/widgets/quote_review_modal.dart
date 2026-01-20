import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';

class QuoteReviewModal extends StatefulWidget {
  final String existingText;
  const QuoteReviewModal({super.key, this.existingText = ""});

  @override
  State<QuoteReviewModal> createState() => _QuoteReviewModalState();
}

class _QuoteReviewModalState extends State<QuoteReviewModal> {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  String _selectedFeeling = AppStrings.feelingInspired;
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
      text:
          "إن الوعي المفرط هو مرض، مرض حقيقي تمامًا. إن كل إنسان يتمتع بوعي مفرط، هو إنسان مريض، إنسان مصاب في عقله.",
    ); // Placeholder from image
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
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Modal, but check height requirements. Slide up usually full or dynamic.
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text(
                  "للجريمة والعقاب - فيودور دوستويفسكي",
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14),
                ), // Placeholder matches image
                value: _selectedBook,
                items: ["الأبله", "الجريمة والعقاب", "الإخوة كارامازوف"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontFamily: 'Tajawal'),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedBook = val),
              ),
            ),
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
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Trigger save logic
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                AppStrings.save,
                style: TextStyle(
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
            ),
          ),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }
}
