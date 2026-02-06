import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../screens/market_screen.dart';

class LimitWarningSheet extends StatelessWidget {
  final bool isScanning;

  const LimitWarningSheet({
    super.key,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

          Padding(
            padding: EdgeInsets.all(24.0.w(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isScanning
                          ? Icons.document_scanner_rounded
                          : Icons.edit_note_rounded,
                      size: 40.sp(context),
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(height: 24.h(context)),

                // Title (Literary)
                Text(
                  'المعرفة لا حدود لها.. ولكن',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 12.h(context)),

                // Description (Philosophical)
                Text(
                  isScanning
                      ? "لقد استنفدت صفحاتك المجانية لهذا الشهر. التقنية جسرٌ للمعرفة، وعبر 'جليس برو' يمكنك عبور هذا الجسر بلا توقف."
                      : "امتلأت محبرتك المجانية. الاقتباسات هي روح الكتب، ولا ينبغي لروحك أن تتوقف عن الجمع. انطلق بلا قيود مع النسخة الاحترافية.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp(context),
                    height: 1.5,
                    color: AppColors.textSub,
                  ),
                ),
                SizedBox(height: 32.h(context)),

                // Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r(context)),
                    gradient: AppColors.refiMeshGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 12.r(context),
                        offset: Offset(0, 4.h(context)),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarketScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r(context)),
                      ),
                    ),
                    child: Text(
                      'أبحر بلا قيود مع جليس برو',
                      style: TextStyle(
                        fontSize: 16.sp(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h(context)),

                // Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'سأكتفي بما لدي الآن',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 14.sp(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
