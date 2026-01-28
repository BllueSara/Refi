import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/subscription_manager.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../../subscription/presentation/screens/market_screen.dart';
import '../../../contact_us/presentation/pages/contact_us_page.dart';
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
  String _currentPlanName = AppStrings.planBasic;

  @override
  void initState() {
    super.initState();
    _loadPlanName();
  }

  Future<void> _loadPlanName() async {
    try {
      final planName = await di.sl<SubscriptionManager>().getCurrentPlanName();
      if (mounted) {
        setState(() {
          _currentPlanName = planName;
        });
      }
    } catch (e) {
      debugPrint('Error loading plan name: $e');
    }
  }

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
          ).textTheme.headlineMedium?.copyWith(fontSize: 20.sp(context)),
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
                  Text(state.message,
                      style: TextStyle(fontSize: 14.sp(context))),
                  SizedBox(height: 16.h(context)),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: Text('Retry',
                        style: TextStyle(fontSize: 14.sp(context))),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.paddingL.w(context)),
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
                      final profileCubit = context.read<ProfileCubit>();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (bottomSheetContext) => BlocProvider.value(
                          value: profileCubit,
                          child: AvatarSelectionBottomSheet(
                            onAvatarSelected: (newAvatarUrl) {
                              profileCubit.updateProfile(
                                  avatarUrl: newAvatarUrl);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.paddingXL.h(context)),

                  // Stats Section
                  _StatsSection(
                    finishedBooks: profile.finishedBooksCount,
                    totalQuotes: profile.totalQuotesCount,
                  ),
                  SizedBox(height: AppDimensions.paddingL.h(context)),

                  // Settings Section
                  // Subscription Plan
                  ProfileOptionTile(
                    title: AppStrings.subscriptionPlan,
                    showArrow: true,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w(context),
                        vertical: 6.h(context),
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.refiMeshGradient,
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                      child: Text(
                        _currentPlanName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12.sp(context),
                            ),
                      ),
                    ),
                    onTap: () async {
                      // Navigate to market screen and refresh plan name when returning
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarketScreen(),
                        ),
                      );
                      // Refresh plan name after returning from market screen
                      _loadPlanName();
                    },
                  ),
                  SizedBox(height: AppDimensions.paddingM.h(context)),
                  ProfileOptionTile(
                    title: AppStrings.annualGoal,
                    showArrow: false,
                    trailing: Text(
                      "${profile.annualGoal ?? 24} ${AppStrings.book}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                    ),
                    onTap: () {
                      // Open Annual Goal Edit
                    },
                  ),
                  SizedBox(height: AppDimensions.paddingM.h(context)),
                  ProfileOptionTile(
                    title: AppStrings.changePassword,
                    showArrow: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<AuthCubit>(),
                            child: const ForgotPasswordScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.paddingM.h(context)),
                  ProfileOptionTile(
                    title: AppStrings.contactUs,
                    showArrow: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppDimensions.paddingXL.h(context)),

                  // Logout Section
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.2),
                          builder: (context) => CustomLogoutDialog(
                            onLogout: () {
                              Navigator.pop(context);
                              context.read<AuthCubit>().signOut();
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18.h(context)),
                        side: const BorderSide(
                          color: AppColors.errorRed,
                          // width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS.r(context)),
                        ),
                      ),
                      child: Text(
                        AppStrings.logout,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorRed,
                              fontSize: 16.sp(context),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingL.h(context)),
                  Text(
                    "${AppStrings.appVersion} 1.0.0",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSub,
                          fontSize: 12.sp(context),
                        ),
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

// Stats Section Widget
class _StatsSection extends StatelessWidget {
  final int finishedBooks;
  final int totalQuotes;

  const _StatsSection({
    required this.finishedBooks,
    required this.totalQuotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingL.w(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r(context),
            offset: Offset(0, 4.h(context)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'الكتب المنجزة',
              value: finishedBooks.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 40.h(context),
            color: AppColors.inputBorder,
          ),
          Expanded(
            child: _StatItem(
              label: 'إجمالي الاقتباسات',
              value: totalQuotes.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                fontSize: 28.sp(context),
              ),
        ),
        SizedBox(height: 4.h(context)),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSub,
                fontSize: 14.sp(context),
              ),
          textAlign: TextAlign.center,
        ),
      ],
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
                width: 100.w(context),
                height: 100.h(context),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.avatarUrl == null ? AppColors.inputBorder : null,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.primaryBlue.withOpacity(0.3), // Blue Glow
                      blurRadius: 15.r(context),
                      offset: Offset(0, 4.h(context)),
                    ),
                  ],
                ),
                child: widget.avatarUrl == null
                    ? Icon(Icons.person,
                        size: 50.sp(context), color: Colors.grey)
                    : widget.avatarUrl!.contains('/svg') ||
                            widget.avatarUrl!.endsWith('.svg')
                        ? ClipOval(
                            child: SvgPicture.network(
                              widget.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Container(
                                color: AppColors.inputBorder,
                                child: Icon(Icons.person,
                                    size: 50.sp(context), color: Colors.grey),
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              widget.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.inputBorder,
                                child: Icon(Icons.person,
                                    size: 50.sp(context), color: Colors.grey),
                              ),
                            ),
                          ),
              ),
              Positioned(
                bottom: 0,
                left:
                    0, // Using Left since RTL might be active or standard visual
                child: Container(
                  padding: EdgeInsets.all(6.w(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inputBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.r(context),
                        offset: Offset(0, 2.h(context)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 14.sp(context),
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h(context)),

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
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 22.sp(context),
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
            SizedBox(width: 8.w(context)),
            if (!_isEditing)
              GestureDetector(
                onTap: () {
                  setState(() => _isEditing = true);
                  _focusNode.requestFocus();
                },
                child: Container(
                  padding: EdgeInsets.all(8.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16.sp(context),
                    color: AppColors.primaryBlue, // "Refi Blue" pencil
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 4.h(context)),

        // Read-only Email
        Text(
          widget.email,
          style: TextStyle(
            //fontFamily: 'Tajawal',
            fontSize: 14.sp(context),
            color: AppColors.textSub,
          ),
        ),
      ],
    );
  }
}
