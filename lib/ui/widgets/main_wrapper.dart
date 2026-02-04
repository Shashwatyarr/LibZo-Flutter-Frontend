import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
// Apne screens import karein
import 'package:bookproject/ui/screens/home_screen.dart';
import 'package:bookproject/ui/screens/feed_screen.dart';
import 'package:bookproject/ui/screens/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Pages ki list jo navigation se switch hogi
  final List<Widget> _pages = [
    const HomeScreen(),            // Index 0
    const Center(child: Text("Search")), // Index 1 (placeholder)
    const FeedScreen(),            // Index 2 (Video/Feed)
    const ProfileAnalyticsPage(),   // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      // IndexedStack state maintain rakhta hai (scroll position change nahi hogi)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: _buildCenterFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 2),
        color: const Color(0xFF0A0A0A).withOpacity(0.5),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.search, 1),
            const SizedBox(width: 40), // FAB ke liye gap
            _buildNavItem(Icons.play_circle_filled_outlined, 2, showDot: true),
            _buildNavItem(Icons.account_circle_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0657F9)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.black, size: 28),
        onPressed: () {
          // Yahan 'Add' action handle karein
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool showDot = false}) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white38, size: 24),
          const SizedBox(height: 4),
          // Active index par mint dot ya custom logic
          Container(
            width: 4, height: 4,
            decoration: BoxDecoration(
              color: (isActive || (showDot && index == 2)) ? const Color(0xFF00F5D4) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}