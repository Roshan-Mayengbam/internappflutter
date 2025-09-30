import 'package:flutter/material.dart';
import 'package:internappflutter/home/home_page.dart';
import 'package:internappflutter/profile/profile.dart';
import 'package:internappflutter/profile/profile2.dart';
import 'package:internappflutter/search/job_search.dart';

class BottomnavbarAlternative extends StatefulWidget {
  const BottomnavbarAlternative({super.key, required userData});

  @override
  State<BottomnavbarAlternative> createState() =>
      _BottomnavbarAlternativeState();
}

class _BottomnavbarAlternativeState extends State<BottomnavbarAlternative> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(userData: null),
    const JobSearchScreen(),
    const Center(child: Text("Calendar Page")),
    const ProfilePage2(),
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
