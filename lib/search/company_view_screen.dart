import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyViewScreen extends StatelessWidget {
  const CompanyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              InkWell(
                onTap: () {
                  Navigator.pop(context); // 👈 Goes back to previous route
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
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
                      // Bottom-right corner shadow
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),

              // Company Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Lumel Technologies ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.jost().fontFamily,
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ],
                  ),
                  Image.asset(
                    'assets/images/Lumel_Logo.png',
                    width: 92,
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Coimbatore, Tamil Nadu, India · 3 weeks ago",
                style: TextStyle(fontFamily: GoogleFonts.jost().fontFamily),
              ),
              Text(
                "Over 100 people clicked apply",
                style: TextStyle(fontFamily: GoogleFonts.jost().fontFamily),
              ),
              const SizedBox(height: 15),

              // Chat button
              Container(
                width: 228,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
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
                    // Bottom-right corner shadow
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 2,
                    ),
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 2,
                    ),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, color: Colors.black),
                  label: Text(
                    "Chat With Recruiter",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: GoogleFonts.jost().fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TabChip(label: "About", isSelected: true),
                    const SizedBox(width: 10),
                    TabChip(label: "People"),
                    const SizedBox(width: 10),
                    TabChip(label: "Post"),
                    const SizedBox(width: 10),
                    TabChip(label: "Jobs"),
                    const SizedBox(width: 10),
                    TabChip(label: "More"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Details Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Company Overview",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: GoogleFonts.jost().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          style: TextStyle(
                            fontFamily: GoogleFonts.jost().fontFamily,
                            fontSize: 18,
                          ),
                          "Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum",
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Responsibilities",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.jost().fontFamily,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          style: TextStyle(
                            fontFamily: GoogleFonts.jost().fontFamily,
                            fontSize: 18,
                          ),
                          "Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum",
                        ),
                        SizedBox(height: 10),
                        Text(
                          style: TextStyle(
                            fontFamily: GoogleFonts.jost().fontFamily,
                            fontSize: 18,
                          ),
                          "Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum Lorem pesum",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const TabChip({super.key, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green[100] : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Jost',
          fontSize: 12,
        ),
      ),
    );
  }
}
