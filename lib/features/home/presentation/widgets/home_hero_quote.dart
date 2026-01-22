import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class HomeHeroQuote extends StatelessWidget {
  final String quote;
  final String author;

  const HomeHeroQuote({super.key, required this.quote, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: const TextStyle(
              //fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Share Button with Micro-interaction
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implement share logic
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
              ),
              Text(
                author,
                style: const TextStyle(
                  //fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
