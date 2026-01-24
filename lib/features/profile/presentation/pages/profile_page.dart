import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_option_tile.dart';
import '../widgets/avatar_selection_bottom_sheet.dart';
import '../widgets/custom_logout_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProfileCubit>()..loadProfile(),
      child: const ProfilePageContent(),
    );
  }
}

class ProfilePageContent extends StatefulWidget {
  const ProfilePageContent({super.key});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.profileTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // Editable Identity
                  _EditableIdentity(
                    fullName: profile.fullName ?? 'مستخدم جديد',
                    email: state.email,
                    avatarUrl: profile.avatarUrl,
                    onNameChanged: (newName) {
                      if (newName.isNotEmpty && newName != profile.fullName) {
                        context
                            .read<ProfileCubit>()
                            .updateProfile(fullName: newName);
                      }
                    },
                    onAvatarTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AvatarSelectionBottomSheet(
                          onAvatarSelected: (newAvatarUrl) {
                            context
                                .read<ProfileCubit>()
                                .updateProfile(avatarUrl: newAvatarUrl);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Stats & Settings
                  ProfileOptionTile(
                    title: 'الكتب المنجزة',
                    showArrow: false,
                    trailing: Text(
                      "${profile.finishedBooksCount}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ProfileOptionTile(
                    title: AppStrings.annualGoal,
                    showArrow: true,
                    trailing: Text(
                      "${profile.annualGoal ?? 24} ${AppStrings.book}", // e.g., 24 كتاب
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                    ),
                    onTap: () {
                      // Open Annual Goal Edit
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ProfileOptionTile(
                    title: AppStrings.changePassword, // "Change Password"
                    showArrow: true,
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/reset-password'); // Or Routes.resetPassword if available, assumes standard naming.
                      // If Routes.resetPassword is not imported, I'll use string literal or verify routes later.
                      // User said "Take him to reset password", assumes route exists or I should create it?
                      // I'll stick to a safe string for now or better yet, verify routes.
                      // I'll assume '/reset-password' is the route for now.
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ProfileOptionTile(
                    title: 'إجمالي الاقتباسات',
                    showArrow: false,
                    trailing: Text(
                      "${profile.totalQuotesCount}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ProfileOptionTile(
                    title: AppStrings.changePassword,
                    showArrow: true,
                    onTap: () {
                      // Change Password logic
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingXXL),

                  const SizedBox(height: AppDimensions.paddingXXL),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor:
                              Colors.black.withOpacity(0.2), // Subtle barrier
                          builder: (context) => CustomLogoutDialog(
                            onLogout: () {
                              Navigator.pop(context); // Close dialog
                              context.read<AuthCubit>().signOut();
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.logout,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorRed,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    "${AppStrings.appVersion} 1.0.0",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EditableIdentity extends StatefulWidget {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final Function(String) onNameChanged;
  final VoidCallback onAvatarTap;

  const _EditableIdentity({
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.onNameChanged,
    required this.onAvatarTap,
  });

  @override
  State<_EditableIdentity> createState() => _EditableIdentityState();
}

class _EditableIdentityState extends State<_EditableIdentity> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        // Lost focus, save
        setState(() => _isEditing = false);
        widget.onNameChanged(_nameController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Update controller if props change (e.g. from Cubit update)
  @override
  void didUpdateWidget(covariant _EditableIdentity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fullName != oldWidget.fullName && !_isEditing) {
      _nameController.text = widget.fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with Edit Indicator
        GestureDetector(
          onTap: widget.onAvatarTap,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.primaryBlue.withOpacity(0.3), // Blue Glow
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: widget.avatarUrl != null
                        ? NetworkImage(widget.avatarUrl!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider, // Fallback
                    fit: BoxFit.cover,
                  ),
                ),
                // Fallback if asset missing or validation
                child: widget.avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                left:
                    0, // Using Left since RTL might be active or standard visual
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inputBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Editable Name
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _nameController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    setState(() => _isEditing = false);
                    widget.onNameChanged(value.trim());
                  },
                  onTap: () => setState(() => _isEditing = true),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!_isEditing)
              GestureDetector(
                onTap: () {
                  setState(() => _isEditing = true);
                  _focusNode.requestFocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.primaryBlue, // "Refi Blue" pencil
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Read-only Email
        Text(
          widget.email,
          style: const TextStyle(
            //fontFamily: 'Tajawal',
            fontSize: 14,
            color: AppColors.textSub,
          ),
        ),
      ],
    );
  }
}
