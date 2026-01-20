import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        AppStrings.scanTitle,
        style: TextStyle(fontFamily: 'Tajawal', fontSize: 18),
      ),
    );
  }
}
