import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../scanner/presentation/pages/scanner_page.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String _activeTab = AppStrings.tabAll; // Reusing "الكل"

  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.filterByBook,
    AppStrings.filterFavorites,
  ];

  final List<Map<String, String>> _mockQuotes = [
    {
      "text": "العلم يبني بيوتاً لا عماد لها\nوالجهل يهدم بيت العز والكرم",
      "book": "مقدمة ابن خلدون",
    },
    {
      "text": "إنما الأمم الأخلاق ما بقيت\nفإن هم ذهبت أخلاقهم ذهبوا",
      "book": "ديوان أحمد شوقي",
    },
    {
      "text":
          "القراءة تمد العقل فقط بلوازم المعرفة، أما التفكير فهو الذي يجعل ما نقرأه ملكاً لنا",
      "book": "التربية والتعليم",
    },
    {
      "text": "ليس الفتى من يقول كان أبي،\nولكن الفتى من قال ها أنا ذا",
      "book": "الأدب العربي",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search, color: AppColors.textMain, size: 28),
          onPressed: () {},
        ),
        title: const Text(
          AppStrings.quotesVaultTitle, // "اقتباساتي"
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textMain,
          ),
        ),
        actions: const [SizedBox(width: 48)], // Balance leading
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: _tabs.map((tab) {
                final isActive = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.refiMeshGradient : null,
                        color: isActive ? null : AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.textSub,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Quote List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockQuotes.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quote = _mockQuotes[index];
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote["text"]!,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black, // "bold black"
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.bookmark,
                                size: 16,
                                color: AppColors.textSub,
                              ), // Book icon
                              const SizedBox(width: 8),
                              Text(
                                quote["book"]!,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  color: AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.share,
                            size: 20,
                            color: AppColors.textPlaceholder,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open Scanner
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const ScannerPage()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.refiMeshGradient,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
      // Wait, bottom nav has "Quotes" tab which leads here. The prompt says "Navigation: Persistent Bottom Navigation Bar with 'اقتباساتي' (اكتشف/مسح) as the active blue icon."
      // Actually image shows "مكتبتي" was the previously requested one.
      // The prompt says "Navigation: Persistent Bottom Navigation Bar with 'اقتباساتي' (اكتشف/مسح) as the active blue icon."
      // Does he mean the Scanner is the main action? Or Quotes page?
      // "Quotes Vault (اقتباساتي) ... Navigation: Persistent Bottom Navigation Bar with 'اقتباساتي'..."
      // So this page is one of the main tabs.
      // And the "Scanner" is accessed via FAB or "Discover/Scan" button.
      // Let's assume this page `QuotesPage` IS the main tab content.
      // And I'll add a FAB here to launch scanner as well, or rely on the "Scan" tab if logic dictates.
      // Re-reading: "Persistent Bottom Navigation Bar with 'اقتباساتي' (اكتشف/مسح) as the active blue icon."
      // It seems he might want "Scan" to be the tab itself? Or "Quotes" is the tab?
      // Usually "Quotes" is the vault. "Scan" is an action.
      // In `MainNavigationScreen`, we have: Home, Discover, Library, Stats, Profile.
      // Where does "Quotes" fit?
      // Maybe "Discover" is "Quotes/Scan"?
      // Or I should replace one?
      // User Prompt 1: "Implement Home Dashboard"
      // User Prompt 2: "Implement My Library"
      // User Prompt 3: "Implement ... Quotes Vault"
      // In `MainNavigationScreen` (Step 804 view):
      // indices: 0: Home, 1: Discover, 2: Library, 3: Stats, 4: Profile.
      // I will put QuotesPage in index 1 (Discover) or maybe just replace "Stats" or add it.
      // Let's replace "Discover" with "Quotes" or "Scan"?
      // The prompt says: "Persistent Bottom Navigation Bar with 'اقتباساتي' (اكتشف/مسح) as the active blue icon."
      // Maybe the 2nd tab is "Quotes" or "Scan".
      // I'll put `QuotesPage` in the MainNavigationScreen.
    );
  }
}
