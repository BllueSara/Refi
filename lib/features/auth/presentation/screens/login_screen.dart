import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';
import '../widgets/refi_social_button.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../../../../core/widgets/main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            const AuthHeader(
              title: AppStrings.loginTitle,
              subtitle: AppStrings.welcomeBack,
            ),

            // Email
            const RefiAuthField(
              label: AppStrings.emailLabel,
              hintText: AppStrings.enterEmailHint,
            ),
            const SizedBox(height: 16),

            // Password
            const RefiAuthField(
              label: AppStrings.passwordLabel,
              hintText: AppStrings.enterPasswordHint,
              isPassword: true,
            ),

            // Forgot Password (Aligned Left for RTL context so "Start" means visual Right)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  AppStrings.forgotPasswordLink,
                  style: TextStyle(
                    color: AppColors
                        .secondaryBlue, // Usually simpler blue for links
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(
                      alpha: 0.2,
                    ), // Fix deprecation later if needed
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement actual login logic (BLoC)
                  // For now, navigate to Home as requested
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: const Text(
                  AppStrings.loginButton,
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
                    AppStrings.orSocialLogin,
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

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.dontHaveAccount,
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
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    AppStrings.registerNow,
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
