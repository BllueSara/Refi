import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'section_header.dart';

class QuoteTextFieldSection extends StatelessWidget {
  final TextEditingController controller;

  const QuoteTextFieldSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: AppStrings.quoteTextLabel,
          icon: Icons.format_quote_rounded,
        ),
        SizedBox(height: 12.h(context)),
        Container(
          padding: EdgeInsets.all(18.w(context)),
          decoration: BoxDecoration(
            color: AppColors.inputBorder.withOpacity(0.5),
            border: Border.all(
              color: AppColors.inputBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 6,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp(context),
              height: 1.6,
              color: AppColors.textMain,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'اكتب أو الصق نص الاقتباس هنا...',
              hintStyle: TextStyle(
                color: AppColors.textPlaceholder,
                fontSize: 14.sp(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
