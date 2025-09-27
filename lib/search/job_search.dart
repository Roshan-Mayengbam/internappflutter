import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/search/company_view_screen.dart';

class JobSearchScreen extends StatelessWidget {
  const JobSearchScreen({super.key});

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
              // Back button + Search bar
              Row(
                children: [
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

                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7C3FF),
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
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          border: InputBorder.none,
                          hintText: "Search jobs",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontFamily: GoogleFonts.jost().fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Recent Search header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Search",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.jost().fontFamily,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Clear",
                      style: TextStyle(
                        fontFamily: GoogleFonts.jost().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChipWidget(label: "Featured", isSelected: true),
                    const SizedBox(width: 10),
                    FilterChipWidget(label: "Live"),
                    const SizedBox(width: 10),
                    FilterChipWidget(label: "Upcoming"),
                    const SizedBox(width: 10),
                    FilterChipWidget(label: "Always Open"),
                    const SizedBox(width: 10),
                    FilterChipWidget(label: "Archived"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Job cards
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Image.asset('assets/images/UI.png'),
                        ),
                        title: const Text(
                          "UI/UX Designer",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("1 week ago"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompanyViewScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
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
          ),
        ),
      ),
      onTap: () => {
        isSelected
            ? true
            : ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label filter selected'))),
      },
    );
  }
}
