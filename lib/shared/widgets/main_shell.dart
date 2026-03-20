import 'package:flutter/material.dart';

import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_list_screen.dart';
import '../../features/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    JournalListScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFFEDEDE7),
        indicatorColor: const Color(0xFF3B5444),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _onNavTap,
        destinations: [
          _navDest(Icons.home_outlined, Icons.home_rounded, 'HOME'),
          _navDest(Icons.menu_book_outlined, Icons.menu_book_rounded, 'JOURNAL'),
          _navDest(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'HISTORY'),
          _navDest(Icons.settings_outlined, Icons.settings_rounded, 'SETTINGS'),
        ],
      ),
    );
  }

  NavigationDestination _navDest(
      IconData icon, IconData activeIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, size: 22, color: const Color(0xFF8A8A82)),
      selectedIcon: Icon(activeIcon, size: 22, color: Colors.white),
      label: label,
    );
  }
}
