import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';

import 'package:internappflutter/home/home_page.dart';

import 'package:internappflutter/screens/job_page.dart';
import 'package:internappflutter/screens/profile_screen.dart';
import 'package:internappflutter/features/NewsFeed/presentation/screen/explore_page.dart';

class BottomnavbarAlternative extends StatefulWidget {
  const BottomnavbarAlternative({super.key, required userData});

  @override
  State<BottomnavbarAlternative> createState() =>
      _BottomnavbarAlternativeState();
}

class _BottomnavbarAlternativeState extends State<BottomnavbarAlternative> {
  int _selectedIndex = 0;

  // Initialize pages once to prevent rebuilding and API calls
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Create pages only once when widget initializes
    _pages = [
      const HomePage(userData: null),
      ExplorePage(),
      const JobPage(),
      const ProfileScreenPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to preserve page state and avoid rebuilding
      extendBody: true, // Extend body behind bottom nav bar

      backgroundColor: AppColors.scaffold,
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.transparent, // Make container transparent
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: _selectedIndex == 0
                          ? const Color(0xFF4BFF3D)
                          : const Color.fromARGB(255, 9, 9, 9),
                      size: 30,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: _selectedIndex == 1
                          ? const Color(0xFF4BFF3D)
                          : const Color.fromARGB(255, 15, 13, 13),
                      size: 28,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: _selectedIndex == 2
                          ? const Color(0xFF4BFF3D)
                          : const Color.fromARGB(255, 4, 3, 3),
                      size: 28,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color: _selectedIndex == 3
                          ? const Color(0xFF4BFF3D)
                          : const Color.fromARGB(255, 13, 13, 13),
                      size: 28,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
