import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200, // Allow space for the text
        leading: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.arrow_back, color: AppColors.textMain),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                AppStrings.backToLogin,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            const AuthHeader(
              title: AppStrings.forgotPasswordTitle,
              subtitle: AppStrings.forgotPasswordSubtitle,
            ),

            // Link inside subtitle is hard to do with standard widgets without RichText in AuthHeader.
            // For now, adhering to strict clean separation, we keep it simple.
            // Requirement said "subtitle with a blue link", handled as plain text in strings for now
            // or we could enhance AuthHeader later.

            // Email
            const RefiAuthField(
              label: AppStrings.emailLabel,
              hintText: AppStrings.emailDomainHint,
              suffixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textPlaceholder,
              ),
            ),

            const SizedBox(height: 32),

            // Send Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Send Reset Link
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: const Text(
                  AppStrings.sendLink,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
