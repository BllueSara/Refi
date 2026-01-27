import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'الإعدادات',
        style: TextStyle(fontSize: 18.sp(context)),
      ),
    );
  }
}
