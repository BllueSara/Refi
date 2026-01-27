import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'section_header.dart';
import 'feeling_chip.dart';

class FeelingsSelectorSection extends StatelessWidget {
  final String? selectedFeeling;
  final Function(String) onFeelingSelected;

  FeelingsSelectorSection({
    super.key,
    required this.selectedFeeling,
    required this.onFeelingSelected,
  });

  final List<String> _feelings = [
    AppStrings.feelingHappy,
    AppStrings.feelingSad,
    AppStrings.feelingInspired,
  ];

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
          children: _feelings
              .map((feeling) => FeelingChip(
                    feeling: feeling,
                    isSelected: selectedFeeling == feeling,
                    onTap: () => onFeelingSelected(feeling),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
