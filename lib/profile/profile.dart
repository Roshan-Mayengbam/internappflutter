import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D7FF), // Light purple background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and edit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow (to make it symmetric)
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  Text(
                    'My Profile',
                    style: GoogleFonts.ptSerif(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.grey,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow (to make it symmetric)
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Profile name and resume button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Raj',
                    style: GoogleFonts.ptSerif(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.grey,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        209,
                        255,
                        182,
                      ), // light green bg
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: const Text(
                      "Resume",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Profession and location
              const Row(
                children: [
                  Text(
                    'Designer',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(width: 40),
                  Text(
                    'Newyork',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(
                color: Color.fromARGB(255, 222, 198, 198),
                thickness: 1,
                height: 30,
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(number: '542', label: 'Followers'),
                    _StatItem(number: '98k', label: 'Following'),
                    _StatItem(number: '100k', label: 'likes'),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(
                color: Color.fromARGB(255, 222, 198, 198),
                thickness: 1,
                height: 30,
              ),

              // About section
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Manage the qualifications or preference used to hide jobs from your searchManage the qualifications or preference used to hide jobs from your searchManage the qualifications or preference used to hide jobs from your search',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Projects section
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Manage the qualifications or preference used to hide jobs from your searchManage the qualifications or preference used to hide jobs from your searchManage the qualifications or preference used to hide jobs from your search',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Tool section
              const Text(
                'Tool',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              // Tool items in 2x2 grid
              const Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage the qualifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Manage the qualifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage the qualifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Manage the qualifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.ptSerif(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
