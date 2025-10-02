import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/models/usermodel.dart';
import 'package:internappflutter/screens/edit_profile_screen.dart';
import 'package:internappflutter/screens/resume_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<Map<String, dynamic>?> fetchStudentDetails() async {
    final idToken = await _auth.currentUser?.getIdToken();
    print("🔑 Firebase ID Token: $idToken");
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.161:3000/student/StudentDetails'),
        headers: {
          'Content-Type': 'application/json',
          // Add Firebase token if your backend requires auth
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        userData = jsonDecode(response.body);
        print("✅ User fetched: $userData");
        user = userData?['user'];

        return user;
      } else {
        print("❌ Error fetching user: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching user: $e");
      return null;
    }
  }

  Widget profilePicWidget() {
    final profilePicUrl = user?['profile']?['profilePicture'] ?? '';
    debugPrint('Profile Picture URL: $profilePicUrl');

    if (profilePicUrl == null || profilePicUrl.isEmpty) {
      return CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50));
    }

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // optional rounded corners
        image: DecorationImage(
          image: NetworkImage(profilePicUrl),
          fit: BoxFit.cover, // fills the container
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? skills = user?['user_skills'];
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userData == null) {
      return const Scaffold(body: Center(child: Text("No user data found")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4F5),
      body: Stack(
        children: [
          // Background image section
          Container(
            height: 450,
            width: double.infinity,
            color: Colors.black,
            child: profilePicWidget(),
          ),

          // Draggable sheet with content
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9E4F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name and Resume button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user!['profile']['FullName'] ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.jost().fontFamily,
                              color: Colors.black,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ResumeEditPopupUtils.showResumeEditPopup(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6F59A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Resume',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: GoogleFonts.jost().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Contact info
                      Text(
                        '${user!['phone'] ?? ''}  ${user!['email'] ?? ''}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bio
                      Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user!['profile']['bio'] ?? '',
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: GoogleFonts.jost().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // About
                      // Text(
                      //   'About',
                      //   style: TextStyle(
                      //     fontSize: 25,
                      //     fontWeight: FontWeight.bold,
                      //     fontFamily: GoogleFonts.jost().fontFamily,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      // const SizedBox(height: 5),
                      // Text(
                      //   userData!['about'] ?? '',
                      //   style: TextStyle(
                      //     color: const Color(0xFF100739),
                      //     fontFamily: GoogleFonts.jost().fontFamily,
                      //   ),
                      // ),
                      const SizedBox(height: 20),

                      // College Details
                      Text(
                        'College Details',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          color: const Color(0xFF100739),
                        ),
                      ),
                      const SizedBox(height: 5),

                      _buildInputField(
                        'College Name',
                        user!['education']['college'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'University Type',
                        user!['education']['universityType'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'Degree',
                        user!['education']['degree'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'College Email ID',
                        user!['education']['collegeEmail'] ?? 'Not Provided',
                      ),
                      const SizedBox(height: 20),

                      // Skills
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            skills?.entries.map((entry) {
                              final skill = entry.key;
                              final level = entry.value['level'];
                              return _buildSkillsSection(
                                skill as Map<String, dynamic>,
                                level,
                              ); // pass skill + level
                            }).toList() ??
                            [Text('No Skills Added')],
                      ),

                      const SizedBox(height: 20),

                      // Job Preferences
                      _buildJobPreferenceSection(
                        userData!['jobPreferences'] ?? [],
                      ),
                      const SizedBox(height: 20),

                      // Experience
                      _buildExperienceSection(userData!['experience'] ?? []),
                      const SizedBox(height: 20),

                      // Projects
                      _buildProjectsSection(userData!['projects'] ?? []),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),

          // Back button
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 25,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Edit button
          Positioned(
            top: 40,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E4F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.jost().fontFamily,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> skills, level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.jost().fontFamily,
            color: const Color(0xFF100739),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: skills.entries.map((entry) {
            final skill = entry.key;
            final level = entry.value['level'] ?? '';
            return _buildSkillChip("$skill - $level", Colors.white);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontFamily: GoogleFonts.jost().fontFamily,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1FA7E3),
        ),
      ),
    );
  }

  Widget _buildJobPreferenceSection(List jobPreferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Preference',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (var job in jobPreferences)
              _buildJobChipWithShadow(job.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildJobChipWithShadow(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontFamily: GoogleFonts.jost().fontFamily,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1FA7E3),
        ),
      ),
    );
  }

  Widget _buildExperienceSection(List experiences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experience',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (var exp in experiences)
          _buildExperienceCard(
            exp['org'] ?? '',
            exp['position'] ?? '',
            exp['timeline'] ?? '',
            exp['description'] ?? '',
          ),
      ],
    );
  }

  Widget _buildExperienceCard(
    String org,
    String position,
    String timeline,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name of Organization', org),
          _buildDetailRow('Position', position),
          _buildDetailRow('Timeline', timeline),
          _buildDetailRow('Description', description),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(List projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Projects',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (var project in projects)
          _buildProjectCard(
            name: project['name'] ?? '',
            description: project['description'] ?? '',
          ),
      ],
    );
  }

  Widget _buildProjectCard({
    required String name,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name of Project: $name',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Description: $description',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF232323),
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
