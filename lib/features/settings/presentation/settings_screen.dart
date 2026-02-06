import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/subscription_manager.dart';
import '../../subscription/presentation/screens/market_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
          child: Column(
            children: [
              SizedBox(height: 24.h(context)),
              // Subscription Section
              _buildSubscriptionSection(context),

              // Add other settings sections here in future
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الاشتراك',
            style: TextStyle(
              fontSize: 16.sp(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 16.h(context)),
          StreamBuilder<CustomerInfo>(
            stream: sl<SubscriptionManager>().customerInfoStream,
            builder: (context, snapshot) {
              String planName = 'مجاني'; // Free
              bool isActive = false;
              String statusText = 'غير نشط'; // Inactive
              Color statusColor = Colors.grey;

              if (snapshot.hasData) {
                final entitlements = snapshot.data!.entitlements.all;
                final entitlement = entitlements['jalees Pro'];
                if (entitlement?.isActive == true) {
                  isActive = true;
                  statusText = 'نشط';
                  statusColor = AppColors.successGreen;
                  final productId =
                      entitlement!.productIdentifier.toLowerCase();
                  if (productId.contains('monthly') ||
                      productId.contains('شهري')) {
                    planName = 'جليس برو - شهري';
                  } else if (productId.contains('six') ||
                      productId.contains('6')) {
                    planName = 'جليس برو - ممتد';
                  } else if (productId.contains('annual') ||
                      productId.contains('yearly')) {
                    planName = 'جليس برو - سنوي';
                  } else {
                    planName = 'جليس برو';
                  }
                }
              }

              return Row(
                children: [
                  Container(
                    width: 48.w(context),
                    height: 48.h(context),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFDF4E7)
                          : Colors.grey[100], // light orange or grey
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.stars_rounded,
                      color:
                          isActive ? AppColors.warningOrange : Colors.grey[400],
                      size: 24.sp(context),
                    ),
                  ),
                  SizedBox(width: 16.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName,
                          style: TextStyle(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        SizedBox(height: 4.h(context)),
                        Row(
                          children: [
                            Container(
                              width: 8.w(context),
                              height: 8.h(context),
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w(context)),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 13.sp(context),
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isActive)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'ترقية',
                        style: TextStyle(
                          fontSize: 14.sp(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
