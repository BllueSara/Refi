import 'package:flutter/material.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_strings.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/quotes/presentation/pages/quotes_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../core/constants/colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Screens
  // Screens
  List<Widget> get _screens => [
    const HomePage(),
    const LibraryPage(), // Index 1: Library
    const SizedBox(), // Index 2: Scanner (Action)
    const QuotesPage(), // Index 3: Quotes
    const ProfilePage(), // Index 4: Profile
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Open Scanner Modal/Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScannerPage()),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textPlaceholder,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
          ),
          items: [
            // Index 0: Home
            _buildNavItem(
              Icons.home,
              Icons.home_outlined,
              AppStrings.navHome,
              0,
            ),
            // Index 1: Library
            _buildNavItem(
              Icons.book,
              Icons.book_outlined,
              AppStrings.navLibrary,
              1,
            ),
            // Index 2: Scanner Action
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.refiMeshGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.document_scanner, color: Colors.white),
              ),
              label: '',
            ),
            // Index 3: Quotes
            _buildNavItem(
              Icons.format_quote,
              Icons.format_quote_outlined,
              AppStrings.navQuotes,
              3,
            ),
            // Index 4: Profile
            _buildNavItem(
              Icons.person,
              Icons.person_outline,
              AppStrings.navProfile,
              4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    final bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: isSelected
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.refiMeshGradient.createShader(bounds),
              child: Icon(activeIcon),
            )
          : Icon(inactiveIcon),
      label: label,
    );
  }
}
