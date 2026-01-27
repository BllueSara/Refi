import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class AvatarSelectionBottomSheet extends StatelessWidget {
  final Function(String) onAvatarSelected;

  const AvatarSelectionBottomSheet({super.key, required this.onAvatarSelected});

  // Placeholder URLs for premium avatars - All girl names
  final List<String> _avatars = const [
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Mia',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Emma',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Sophia',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Olivia',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Isabella',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Ava',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Charlotte',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Amelia',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Harper',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Evelyn',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Abigail',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Emily',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Ella',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Elizabeth',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Sofia',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Luna',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Grace',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Victoria',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Aria',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Scarlett',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Lily',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Zoe',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Chloe',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Penelope',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Layla',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Nora',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Hannah',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Mila',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Addison',
    'https://api.dicebear.com/9.x/toon-head/svg?seed=Eleanor',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w(context),
            height: 4.h(context),
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2.r(context)),
            ),
          ),
          SizedBox(height: 24.h(context)),
          Text(
            'اختر الصورة الشخصية',
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontSize: 18.sp(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 24.h(context)),
          Flexible(
            child: GridView.builder(
              itemCount: _avatars.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.w(context),
                mainAxisSpacing: 16.h(context),
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onAvatarSelected(_avatars[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.inputBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.r(context),
                          offset: Offset(0, 4.h(context)),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: SvgPicture.network(
                        _avatars[index],
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => Container(
                          color: AppColors.inputBorder,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        semanticsLabel: 'Avatar ${index + 1}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h(context)),
        ],
      ),
    );
  }
}
