import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image + AppBar
          Column(
            children: [
              Container(
                height: 440,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  children: [
                    // Profile Image
                    Image.asset(
                      "assets/images/profile.png",

                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Top AppBar (Back + Title + Edit)
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.white,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          Text(
                            "My Profile",
                            style: GoogleFonts.jost(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.white,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.5, // default height
            minChildSize: 0.5,
            maxChildSize: 0.95, // expanded
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE4C9F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Profile Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "John Raj",
                                  style: GoogleFonts.jost(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF100739),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      "Designer",
                                      style: GoogleFonts.jost(
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      "Newyork",
                                      style: GoogleFonts.jost(
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE3FEAA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Resume",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("542", "Followers"),
                          _buildStat("98k", "Following"),
                          _buildStat("100k", "Likes"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.black26, thickness: 1),

                      // About Section
                      const SizedBox(height: 20),
                      Text(
                        "About",
                        style: GoogleFonts.jost(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Manage the qualifications or preference used to hide jobs from your search. "
                        "Manage the qualifications or preference used to hide jobs from your search.",
                        style: GoogleFonts.jost(fontSize: 14),
                      ),

                      // Projects Section
                      const SizedBox(height: 20),
                      Text(
                        "Projects",
                        style: GoogleFonts.jost(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Manage the qualifications or preference used to hide jobs from your search.",
                        style: GoogleFonts.jost(fontSize: 14),
                      ),

                      // Tools Section
                      const SizedBox(height: 20),
                      Text(
                        "Tool",
                        style: GoogleFonts.jost(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 5,
                        children: List.generate(
                          4,
                          (index) => Text(
                            "Manage the qualifications",
                            style: GoogleFonts.jost(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget for Stats
  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.jost(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF100739),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.jost(
            fontSize: 14,
            color: const Color(0xFF100739).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
