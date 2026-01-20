import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';
import '../widgets/refi_social_button.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            const AuthHeader(
              title: AppStrings.joinRefi,
              subtitle: AppStrings.startYourJourney,
            ),

            // Full Name
            const RefiAuthField(
              hintText: AppStrings.fullNameHint,
              suffixIcon: Icon(Icons.person, color: AppColors.textPlaceholder),
            ),
            const SizedBox(height: 16),

            // Email
            const RefiAuthField(
              hintText: AppStrings.emailHint,
              suffixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textPlaceholder,
              ),
            ),
            const SizedBox(height: 16),

            // Password
            const RefiAuthField(
              hintText: AppStrings.passwordDots,
              isPassword: true,
              suffixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.textPlaceholder,
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password (reusing logic, user might want a separate hint but dots is standard)
            const RefiAuthField(
              hintText: AppStrings.passwordDots,
              isPassword: true,
              suffixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.textPlaceholder,
              ),
            ),

            const SizedBox(height: 32),

            // Create Account Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Perform Sign Up
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: const Text(
                  AppStrings.createAccount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Social
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[200])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.orSocialSignUp,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[200])),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: RefiSocialButton(
                    label: AppStrings.google,
                    icon: SvgPicture.string(
                      AppSvgs.googleLogo,
                      width: 24,
                      height: 24,
                    ),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RefiSocialButton(
                    label: AppStrings.apple,
                    icon: const Icon(
                      Icons.apple,
                      size: 28,
                      color: Colors.black,
                    ),
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Back to Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.haveAccount,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontFamily: 'Tajawal',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    AppStrings.loginLink,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
