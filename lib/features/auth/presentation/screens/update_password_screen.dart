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

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (_newPasswordController.text.trim().isEmpty) {
      setState(() {
        _newPasswordError = 'الرجاء إدخال كلمة المرور الجديدة';
      });
      hasError = true;
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _newPasswordError = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      });
      hasError = true;
    }

    if (_confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _confirmPasswordError = 'الرجاء تأكيد كلمة المرور';
      });
      hasError = true;
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'كلمات المرور غير متطابقة';
      });
      hasError = true;
    }

    if (hasError) return;

    context.read<AuthCubit>().updatePassword(_newPasswordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          RefiSnackBars.show(
            context,
            message: 'تم تغيير كلمة المرور بنجاح',
            type: SnackBarType.success,
          );
          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          setState(() {
            _newPasswordError = state.message;
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
                  title: 'تغيير كلمة المرور',
                  subtitle: 'أدخل كلمة المرور الجديدة',
                ),

                const SizedBox(height: 32),

                // Password fields + button
                Column(
                  children: [
                    // New Password
                    RefiAuthField(
                      controller: _newPasswordController,
                      label: 'كلمة المرور الجديدة',
                      hintText: AppStrings.passwordDots,
                      isPassword: true,
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textPlaceholder,
                      ),
                      errorText: _newPasswordError,
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    RefiAuthField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      hintText: AppStrings.passwordDots,
                      isPassword: true,
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textPlaceholder,
                      ),
                      errorText: _confirmPasswordError,
                    ),

                    const SizedBox(height: 32),

                    // Update Button
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
                        onPressed: isLoading ? null : _onUpdate,
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
                                'تغيير كلمة المرور',
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

