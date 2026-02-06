import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/scale_button.dart';
import '../../domain/entities/home_entity.dart';
import '../../../add_book/presentation/screens/search_screen.dart';
import '../../../subscription/presentation/screens/market_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/subscription_manager.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeData data;

  const HomeHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      title: Row(
        children: [
          // Greeting & Streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("👋", style: TextStyle(fontSize: 20.sp(context))),
                    SizedBox(width: 8.w(context)),
                    Flexible(
                      child: Text(
                        "${AppStrings.hello} ${data.username}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp(context),
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Market Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
          child: ScaleButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketScreen(),
                ),
              );
            },
            child: StreamBuilder<CustomerInfo>(
                stream: sl<SubscriptionManager>().customerInfoStream,
                builder: (context, snapshot) {
                  // Determine Plan Name Logic
                  String buttonText =
                      AppStrings.marketTitle; // Default: 'اختر باقتك'
                  bool isPro = false;

                  if (snapshot.hasData) {
                    final entitlements = snapshot.data!.entitlements.all;
                    final entitlement = entitlements[
                        'jalees Pro']; // Hardcoded ID for now/from Manager
                    if (entitlement?.isActive == true) {
                      isPro = true;
                      // Map product ID to name
                      final productId =
                          entitlement!.productIdentifier.toLowerCase();
                      if (productId.contains('monthly') ||
                          productId.contains('شهري')) {
                        buttonText = 'جليس برو - شهري';
                      } else if (productId.contains('six') ||
                          productId.contains('6')) {
                        buttonText = 'جليس برو - ممتد';
                      } else if (productId.contains('annual') ||
                          productId.contains('yearly')) {
                        buttonText = 'جليس برو - سنوي';
                      } else {
                        buttonText = 'جليس برو';
                      }
                    }
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w(context),
                      vertical: 8.h(context),
                    ),
                    decoration: BoxDecoration(
                      gradient: isPro
                          ? const LinearGradient(colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFFFD54F)
                            ]) // Gold for Pro
                          : AppColors.refiMeshGradient,
                      borderRadius: BorderRadius.circular(16.r(context)),
                      boxShadow: [
                        BoxShadow(
                          color: (isPro
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.primaryBlue)
                              .withOpacity(0.2),
                          blurRadius: 8.r(context),
                          offset: Offset(0, 4.h(context)),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 18.sp(context),
                        ),
                        SizedBox(width: 6.w(context)),
                        Text(
                          buttonText,
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp(context),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          icon: Icon(Icons.search,
              color: AppColors.textMain, size: 28.sp(context)),
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }

  @override
  Size get preferredSize {
    // Include status bar height to prevent covering the clock
    // Default AppBar height is 56, we add extra padding for status bar
    return const Size.fromHeight(kToolbarHeight + 24);
  }
}
