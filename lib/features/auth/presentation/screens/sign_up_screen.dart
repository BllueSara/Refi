import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';
import '../widgets/refi_social_button.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _onSignUp() {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع الحقول')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }

    context.read<AuthCubit>().signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
              ),
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
                RefiAuthField(
                  controller: _nameController,
                  hintText: AppStrings.fullNameHint,
                  suffixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),

                // Email
                RefiAuthField(
                  controller: _emailController,
                  hintText: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // Password
                RefiAuthField(
                  controller: _passwordController,
                  hintText: AppStrings.passwordDots,
                  isPassword: true,
                  suffixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                RefiAuthField(
                  controller: _confirmPasswordController,
                  hintText: AppStrings.passwordDots,
                  isPassword: true,
                  suffixIcon: const Icon(Icons.lock_outline),
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
                    onPressed: state is AuthLoading ? null : _onSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.buttonRadius,
                        ),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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
                        style: Theme.of(context).textTheme.bodySmall,
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
                        onTap: () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RefiSocialButton(
                        label: AppStrings.apple,
                        icon: Icon(
                          Icons.apple,
                          size: 28,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          context.read<AuthCubit>().signInWithApple();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
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
      },
    );
  }
}
