import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/refi_snack_bar.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/refi_auth_field.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSend() {
    setState(() {
      _emailError = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'الرجاء إدخال البريد الإلكتروني';
      });
      return;
    }
    context.read<AuthCubit>().resetPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          RefiSnackBars.show(
            context,
            message:
                'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
            type: SnackBarType.success,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (state is AuthError) {
          setState(() {
            _emailError = state.message;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            forceMaterialTransparency: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              children: [
                // Header
                const AuthHeader(
                  title: AppStrings.forgotPasswordTitle,
                  subtitle: AppStrings.forgotPasswordSubtitle,
                ),

                // Email field + button
                Column(
                  children: [
                    RefiAuthField(
                      controller: _emailController,
                      label: AppStrings.emailLabel,
                      hintText: AppStrings.emailDomainHint,
                      suffixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textPlaceholder,
                      ),
                      errorText: _emailError,
                    ),

                    const SizedBox(height: 32),

                    // Send Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.refiMeshGradient,
                        borderRadius: BorderRadius.circular(
                          AppSizes.buttonRadius,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.buttonRadius,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : const Text(
                                AppStrings.sendLink,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
