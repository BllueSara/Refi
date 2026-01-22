import 'package:flutter/material.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_strings.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/quotes/presentation/pages/quotes_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../core/constants/colors.dart';
import 'bottom_nav_bar_widget.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _libraryInitialTab;

  // Screens
  List<Widget> get _screens => [
        const HomePage(),
        LibraryPage(
          key: ValueKey('library_$_libraryInitialTab'),
          initialTab: _libraryInitialTab,
        ), // Index 1: Library
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

  // Public method to change tab from child widgets
  void changeTab(int index, {String? libraryTab}) {
    if (libraryTab != null && index == 1) {
      // If changing to library tab with a specific filter
      setState(() {
        _libraryInitialTab = libraryTab;
        _currentIndex = index;
      });
    } else {
      _onTabTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        barColor: AppColors.white,
        barGradient: AppColors.refiMeshGradient,
        dotColor: AppColors.primaryBlue,
        dotGradient: AppColors.refiMeshGradient,
        selectedDotColor: AppColors.primaryBlue,
        dotActiveIndex: 2, // Scanner is at index 2
        dotIcon: Icons.document_scanner,
        dotIconColor: Colors.white,
        selectedDotIconColor: Colors.white,
        dotLabel: AppStrings.navScan1,
        dotLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        itemColor: Colors.white,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        items: [
          // Index 0: Home
          BottomNavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: AppStrings.navHome,
            tabIndex: 0,
            onTap: () => _onTabTapped(0),
          ),
          // Index 1: Library
          BottomNavBarItem(
            icon: Icons.book_outlined,
            activeIcon: Icons.book,
            label: AppStrings.navLibrary,
            tabIndex: 1,
            onTap: () => _onTabTapped(1),
          ),
          // Index 3: Quotes (right side of dot)
          BottomNavBarItem(
            icon: Icons.format_quote_outlined,
            activeIcon: Icons.format_quote,
            label: AppStrings.navQuotes,
            tabIndex: 3,
            onTap: () => _onTabTapped(3),
          ),
          // Index 4: Profile
          BottomNavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: AppStrings.navProfile,
            tabIndex: 4,
            onTap: () => _onTabTapped(4),
          ),
        ],
        onDotTap: () => _onTabTapped(2), // Scanner action
      ),
    );
  }
}
