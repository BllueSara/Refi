import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FastLaunchScreen extends StatelessWidget {
  const FastLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a simple text logo if image isn't available, or a spinner
            Text(
              'جليس',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
