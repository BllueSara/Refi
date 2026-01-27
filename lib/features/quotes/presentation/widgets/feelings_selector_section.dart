import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'section_header.dart';
import 'feeling_chip.dart';

class FeelingsSelectorSection extends StatefulWidget {
  final String? selectedFeeling;
  final Function(String) onFeelingSelected;

  const FeelingsSelectorSection({
    super.key,
    required this.selectedFeeling,
    required this.onFeelingSelected,
  });

  @override
  State<FeelingsSelectorSection> createState() =>
      _FeelingsSelectorSectionState();
}

class _FeelingsSelectorSectionState extends State<FeelingsSelectorSection> {
  final List<String> _feelings = [
    AppStrings.feelingHappy,
    AppStrings.feelingSad,
    AppStrings.feelingInspired,
  ];

  bool _showCustomInput = false;
  final TextEditingController _customFeelingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if selected feeling is a custom one
    if (widget.selectedFeeling != null &&
        !_feelings.contains(widget.selectedFeeling)) {
      _customFeelingController.text = widget.selectedFeeling!;
    }
  }

  @override
  void didUpdateWidget(FeelingsSelectorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update custom feeling text if selection changed
    if (widget.selectedFeeling != oldWidget.selectedFeeling) {
      if (widget.selectedFeeling != null &&
          !_feelings.contains(widget.selectedFeeling)) {
        _customFeelingController.text = widget.selectedFeeling!;
      }
    }
  }

  @override
  void dispose() {
    _customFeelingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: AppStrings.feelingLabel,
          icon: Icons.mood_rounded,
        ),
        SizedBox(height: 16.h(context)),
        Wrap(
          spacing: 8.w(context),
          runSpacing: 8.h(context),
          children: [
            // Predefined feelings
            ..._feelings
                .map((feeling) => FeelingChip(
                      feeling: feeling,
                      isSelected: widget.selectedFeeling == feeling,
                      onTap: () {
                        setState(() {
                          _showCustomInput = false;
                          _customFeelingController.clear();
                        });
                        widget.onFeelingSelected(feeling);
                      },
                    ))
                .toList(),
            // Show custom feeling chip if a custom feeling is selected
            if (widget.selectedFeeling != null &&
                !_feelings.contains(widget.selectedFeeling) &&
                !_showCustomInput)
              FeelingChip(
                feeling: widget.selectedFeeling!,
                isSelected: true,
                onTap: () {
                  // Allow editing the custom feeling
                  setState(() {
                    _showCustomInput = true;
                    _customFeelingController.text = widget.selectedFeeling!;
                  });
                },
              ),
            // Custom feeling button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomInput = !_showCustomInput;
                  if (!_showCustomInput) {
                    _customFeelingController.clear();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w(context),
                  vertical: 12.h(context),
                ),
                decoration: BoxDecoration(
                  gradient: _showCustomInput ? AppColors.refiMeshGradient : null,
                  color: _showCustomInput ? null : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(24.r(context)),
                  boxShadow: _showCustomInput
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 8.r(context),
                            offset: Offset(0, 4.h(context)),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCustomInput ? Icons.close : Icons.add_circle_outline,
                      size: 16.sp(context),
                      color: _showCustomInput ? Colors.white : AppColors.textSub,
                    ),
                    SizedBox(width: 6.w(context)),
                    Text(
                      _showCustomInput ? 'إلغاء' : 'شعور آخر',
                      style: TextStyle(
                        fontSize: 14.sp(context),
                        fontWeight: FontWeight.w600,
                        color:
                            _showCustomInput ? Colors.white : AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Custom feeling input field
        if (_showCustomInput) ...[
          SizedBox(height: 16.h(context)),
          AnimatedOpacity(
            opacity: _showCustomInput ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: TextField(
              controller: _customFeelingController,
              autofocus: true,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14.sp(context),
              ),
              decoration: InputDecoration(
                hintText: 'اكتب شعورك هنا...',
                hintStyle: TextStyle(
                  color: AppColors.textPlaceholder,
                  fontSize: 14.sp(context),
                ),
                filled: true,
                fillColor: AppColors.inputBorder.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w(context),
                  vertical: 12.h(context),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: AppColors.primaryBlue,
                    size: 24.sp(context),
                  ),
                  onPressed: () {
                    if (_customFeelingController.text.trim().isNotEmpty) {
                      final customFeeling = _customFeelingController.text.trim();
                      widget.onFeelingSelected(customFeeling);
                      setState(() {
                        _showCustomInput = false;
                      });
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onFeelingSelected(value.trim());
                  setState(() {
                    _showCustomInput = false;
                  });
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}
