import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AvatarSelectionBottomSheet extends StatelessWidget {
  final Function(String) onAvatarSelected;

  const AvatarSelectionBottomSheet({super.key, required this.onAvatarSelected});

  // Placeholder URLs for premium avatars (3 boys, 3 girls)
  /*
    In a real app, replace these with actual asset paths or hosted URLs.
    For now, using standard placeholders but distinguishable.
  */
  final List<String> _avatars = const [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4', // Boy 1
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka&backgroundColor=c0aede', // Girl 1
    'https://api.dicebear.com/7.x/avataaars/png?seed=John&backgroundColor=ffdfbf', // Boy 2
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jane&backgroundColor=ffdfbf', // Girl 2
    'https://api.dicebear.com/7.x/avataaars/png?seed=Mike&backgroundColor=b6e3f4', // Boy 3
    'https://api.dicebear.com/7.x/avataaars/png?seed=Sara&backgroundColor=c0aede', // Girl 3
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'اختر الصورة الشخصية',
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _avatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
                    image: DecorationImage(
                      image: NetworkImage(_avatars[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
