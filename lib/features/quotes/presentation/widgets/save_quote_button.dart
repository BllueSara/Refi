import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class SaveQuoteButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isSaving;

  const SaveQuoteButton({
    super.key,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h(context),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(28.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 12.r(context),
            offset: Offset(0, 6.h(context)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSaving ? null : onSave,
          borderRadius: BorderRadius.circular(28.r(context)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving)
                  SizedBox(
                    width: 22.w(context),
                    height: 22.h(context),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22.sp(context),
                  ),
                SizedBox(width: 12.w(context)),
                Text(
                  isSaving ? 'جاري الحفظ...' : AppStrings.save,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp(context),
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
