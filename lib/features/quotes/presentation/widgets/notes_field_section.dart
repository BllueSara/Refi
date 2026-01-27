import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'section_header.dart';

class NotesFieldSection extends StatelessWidget {
  final TextEditingController controller;

  const NotesFieldSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: AppStrings.notesLabel,
          icon: Icons.note_rounded,
        ),
        SizedBox(height: 12.h(context)),
        Container(
          padding: EdgeInsets.all(18.w(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: AppColors.inputBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(
              fontSize: 14.sp(context),
              color: AppColors.textMain,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.notesHint,
              hintStyle: TextStyle(
                color: AppColors.textPlaceholder,
                fontSize: 14.sp(context),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
