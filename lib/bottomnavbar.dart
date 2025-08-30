import 'package:flutter/material.dart';
import 'package:internappflutter/home/home_page.dart';
import 'package:internappflutter/profile/profile.dart';

class BottomnavbarAlternative extends StatefulWidget {
  const BottomnavbarAlternative({super.key});

  @override
  State<BottomnavbarAlternative> createState() =>
      _BottomnavbarAlternativeState();
}

class _BottomnavbarAlternativeState extends State<BottomnavbarAlternative> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text("Bookmarks Page")),
    const Center(child: Text("Calendar Page")),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70, // Slightly increased height for better proportion
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
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
                          : Colors.black,
                      size: 30,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: _selectedIndex == 1
                          ? const Color(0xFF4BFF3D)
                          : Colors.black,
                      size: 28,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: _selectedIndex == 2
                          ? const Color(0xFF4BFF3D)
                          : Colors.black,
                      size: 28,
                    ),
                    onPressed: () => setState(() => _selectedIndex = 2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color: _selectedIndex == 3
                          ? const Color(0xFF4BFF3D)
                          : Colors.black,
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
