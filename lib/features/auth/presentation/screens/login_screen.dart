import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../../../../core/widgets/no_internet_dialog.dart';
import '../../../../core/services/network_connectivity_service.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';
import '../widgets/refi_social_button.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  NetworkConnectivityService? _connectivityService;

  Future<void> _onLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

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

    if (hasError) return;

    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _connectivityService?.dispose();
    _connectivityService = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          final message = state.message.toLowerCase();

          // Check for network/connection errors
          if (message.contains('network') ||
              message.contains('connection') ||
              message.contains('internet') ||
              message.contains('timeout') ||
              message.contains('socket') ||
              message.contains('failed host lookup') ||
              message.contains('no internet')) {
            // Show no internet dialog for network errors
            NoInternetDialog.show(
              context,
              onRetry: () {
                Navigator.of(context).pop();
                _onLogin();
              },
            );
            return;
          }

          // Security: Always show generic error message to prevent information disclosure
          // Don't reveal whether email exists or which field is wrong
          setState(() {
            _emailError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
            _passwordError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
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
                  // Header
                  const AuthHeader(
                    title: AppStrings.loginTitle,
                    subtitle: AppStrings.welcomeBack,
                  ),

                  // Form (email, password, login)
                  Column(
                    children: [
                      // Email
                      RefiAuthField(
                        controller: _emailController,
                        label: AppStrings.emailLabel,
                        hintText: AppStrings.enterEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      SizedBox(height: 16.h(context)),

                      // Password
                      RefiAuthField(
                        controller: _passwordController,
                        label: AppStrings.passwordLabel,
                        hintText: AppStrings.enterPasswordHint,
                        isPassword: true,
                        errorText: _passwordError,
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.forgotPasswordLink,
                            style: TextStyle(
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp(context),
                              ////fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h(context)),

                      // Login Button
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
                          onPressed: state is AuthLoading ? null : _onLogin,
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
                                  AppStrings.loginButton,
                                  style: TextStyle(
                                    fontSize: 16.sp(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    ////fontFamily: 'Tajawal',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h(context)),

                  // Social + Sign up
                  Column(
                    children: [
                      // Social
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[200])),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16.w(context)),
                            child: Text(
                              AppStrings.orSocialLogin,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14.sp(context),
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
                            child: Text(
                              AppStrings.registerNow,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp(context),
                                ////fontFamily: 'Tajawal',
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
