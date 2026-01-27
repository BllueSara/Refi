import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';
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

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _onSignUp() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'الرجاء إدخال الاسم';
      });
      hasError = true;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'الرجاء إدخال البريد الإلكتروني';
      });
      hasError = true;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'الرجاء إدخال كلمة المرور';
      });
      hasError = true;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'كلمات المرور غير متطابقة';
      });
      hasError = true;
    }

    if (hasError) return;

    context.read<AuthCubit>().signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          setState(() {
            if (state.message.toLowerCase().contains('email')) {
              _emailError = state.message;
            } else {
              _passwordError = state.message;
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.p24.w(context)),
              child: Column(
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerRight, // RTL
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                        size: 24.sp(context),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  // Header
                  const AuthHeader(
                    title: AppStrings.joinRefi,
                    subtitle: AppStrings.startYourJourney,
                  ),

                  // Form + Create account button
                  Column(
                    children: [
                      // Full Name
                      RefiAuthField(
                        controller: _nameController,
                        hintText: AppStrings.fullNameHint,
                        suffixIcon: Icon(Icons.person, size: 20.sp(context)),
                        errorText: _nameError,
                      ),
                      SizedBox(height: 16.h(context)),

                      // Email
                      RefiAuthField(
                        controller: _emailController,
                        hintText: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icon(Icons.email_outlined, size: 20.sp(context)),
                        errorText: _emailError,
                      ),
                      SizedBox(height: 16.h(context)),

                      // Password
                      RefiAuthField(
                        controller: _passwordController,
                        hintText: AppStrings.passwordDots,
                        isPassword: true,
                        suffixIcon: Icon(Icons.lock_outline, size: 20.sp(context)),
                        errorText: _passwordError,
                      ),
                      SizedBox(height: 16.h(context)),

                      // Confirm Password
                      RefiAuthField(
                        controller: _confirmPasswordController,
                        hintText: AppStrings.passwordDots,
                        isPassword: true,
                        suffixIcon: Icon(Icons.lock_outline, size: 20.sp(context)),
                        errorText: _confirmPasswordError,
                      ),

                      SizedBox(height: 32.h(context)),

                      // Create Account Button
                      Container(
                        width: double.infinity,
                        height: 56.h(context),
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(
                            AppSizes.buttonRadius.r(context),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 10.r(context),
                              offset: Offset(0, 4.h(context)),
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
                                AppSizes.buttonRadius.r(context),
                              ),
                            ),
                          ),
                          child: state is AuthLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3.w(context),
                                )
                              : Text(
                                  AppStrings.createAccount,
                                  style: TextStyle(
                                    fontSize: 16.sp(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h(context)),

                  // Social + Back to login
                  Column(
                    children: [
                      // Social
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[200])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                            child: Text(
                              AppStrings.orSocialSignUp,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12.sp(context),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[200])),
                        ],
                      ),
                      SizedBox(height: 24.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: RefiSocialButton(
                              label: AppStrings.google,
                              icon: SvgPicture.string(
                                AppSvgs.googleLogo,
                                width: 24.w(context),
                                height: 24.h(context),
                              ),
                              onTap: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h(context)),

                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.haveAccount,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp(context),
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
                            child: Text(
                              AppStrings.loginLink,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
