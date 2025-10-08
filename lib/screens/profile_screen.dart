import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/screens/edit_profile_screen.dart';
import 'package:internappflutter/screens/resume_edit_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({super.key});

  @override
  State<ProfileScreenPage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenPage> {
  Map<String, dynamic>? userData;
  final User? user = FirebaseAuth.instance.currentUser;
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out from Google and Firebase
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navigate to SignUpScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Page2()),
        (route) => false, // remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign out failed: $e")));
    }
  }

  Future<void> fetchStudentDetails() async {
    setState(() {
      isLoading = true; // ← Change from false to true
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        // Navigate back or to login screen
        Navigator.of(context).pushReplacementNamed('/signup');
        return;
      }

      String uid = user.uid;
      String? idToken = await user.getIdToken();

      if (idToken == null) {
        setState(() {
          errorMessage = "Could not get authentication token";
          isLoading = false;
        });
        return;
      }

      print("🔄 Fetching user details...");

      final response = await http.post(
        Uri.parse('$baseUrl/student/StudentDetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'studentId': uid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['user'];
          isLoading = false;
        });
        print("✅ Fetched user details: $userData");
      } else {
        setState(() {
          errorMessage =
              'Failed to load Student details: ${response.statusCode}';
          isLoading = false;
        });
        print("❌ Failed to load Student details: ${response.statusCode}");
        // Show a snackbar instead
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load profile. Please try again.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: fetchStudentDetails,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print("❌ Error fetching Student details: ${e.toString()}");
      // Show a snackbar for errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: fetchStudentDetails,
            ),
          ),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    // Show loading indicator while fetching data
    if (isLoading || userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9E4F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = userData!['profile'] ?? {};
    final fullName = profile['FullName'] ?? 'No Name';
    final profilePic = profile['profilePicture'] ?? '';
    final bio = profile['bio'] ?? '';
    final phone = userData!['phone'] ?? 'N/A';

    final email = user?.email ?? 'N/A';
    final education = userData!['education'] ?? {};
    final userSkills = userData!['user_skills'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4F5),
      body: Stack(
        children: [
          // Background image section
          Container(
            height: 450,
            width: double.infinity,
            color: Colors.black,
            child: profilePic.isNotEmpty
                ? Image.network(
                    profilePic,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.person, size: 100, color: Colors.white),
          ),

          // Draggable sheet with all content
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                width: 25,
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
                          Expanded(
                            child: Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.jost().fontFamily,
                                color: Colors.black,
                              ),
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
                        phone,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          fontSize: 20,
                        ),
                      ),

                      // Bio section
                      const SizedBox(height: 15),
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
                        bio,
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: GoogleFonts.jost().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'College Details',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.jost().fontFamily,
                          color: Color(0xFF100739),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Education section
                      _buildInputField(
                        'College Name',
                        education['college'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'University',
                        education['universityType'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField('Degree', education['degree'] ?? ''),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'College Email ID',
                        education['collegeEmail'] ?? '',
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        'Year of Graduation',
                        education['yearOfPassing']?.toString() ?? '',
                      ),

                      const SizedBox(height: 20),

                      // Skills section
                      if (userSkills.isNotEmpty) ...[
                        Text(
                          'Skills',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.jost().fontFamily,
                            color: Color(0xFF100739),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: userSkills.keys
                              .map<Widget>(
                                (skillName) =>
                                    _buildSkillChip(skillName, Colors.white),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Job Preference section
                      _buildJobPreferenceSection(),
                      const SizedBox(height: 20),

                      // Experience section
                      _buildExperienceSection(),
                      const SizedBox(height: 20),

                      // Projects section
                      _buildProjectsSection(),
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
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 25,
                ),
                onPressed: () {
                  _signOut(context);
                },
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  // Refresh data if profile was updated
                  if (result == true) {
                    fetchStudentDetails();
                  }
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
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
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
              top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
              left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
              right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
              bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skills',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.jost().fontFamily,
                color: Color(0xFF100739),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 6),
                    blurRadius: 0,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 0),
                    blurRadius: 0,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
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
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  // Make button background transparent so the container shows
                  backgroundColor: const Color(0xFFFDC88D),
                  shadowColor: Colors.transparent, // remove default shadow
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Verify Skills',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: GoogleFonts.jost().fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 50.0,
          runSpacing: 35.0,
          children: [
            _buildSkillChip('ADOBE', const Color(0xFFFDD34F)),
            _buildSkillChip('REACT', Colors.white),
            _buildSkillChip('FLUTTER', const Color(0xFF96E7E5)),
            _buildSkillChip('FIGMA', const Color(0xFF40FFB9)),
            _buildSkillChip('TENSOR FLOW', Colors.white),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color, // Chip background
        boxShadow: const [
          // Bottom shadow
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          // Right shadow
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          // Bottom-right shadow
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ), // optional spacing
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontFamily: GoogleFonts.jost().fontFamily,
          color: const Color(0xFF1FA7E3),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJobPreferenceSection() {
    final jobPreferences = userData?['job_preference'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Preference',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        Wrap(
          spacing: 25.0,
          runSpacing: 30.0,
          children: jobPreferences
              .map<Widget>((job) => _buildJobChipWithShadow(job.toString()))
              .toList(),
        ),
      ],
    );
  }

  // New helper method with shadow
  Widget _buildJobChipWithShadow(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontFamily: GoogleFonts.jost().fontFamily,
          color: const Color(0xFF1FA7E3),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    final experiences = userData?['experience'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: GoogleFonts.jost().fontFamily,
          ),
        ),
        const SizedBox(height: 10),
        ...experiences.map((exp) {
          final org = exp['nameOfOrg'] ?? '';
          final position = exp['position'] ?? '';
          final timeline = exp['timeline'] ?? '';
          final description = exp['description'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: _buildExperienceCard(org, position, timeline, description),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProjectsSection() {
    final projects = userData?['projects'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Projects',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'Jost',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ...projects.map((proj) {
          final name = proj['projectName'] ?? '';
          final description = proj['description'] ?? '';
          final link = proj['link'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildProjectCard(
              name: name,
              description: description,
              link: link,
            ),
          );
        }).toList(),
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

  // Widget _buildProjectCard({
  //   required String name,
  //   required String description,
  //    required link,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 'Name of Project: $name',
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFD3EBFD),
  //                 borderRadius: BorderRadius.circular(10),
  //                 boxShadow: const [
  //                   BoxShadow(
  //                     color: Colors.black,
  //                     offset: Offset(0, 6),
  //                     blurRadius: 0,
  //                     spreadRadius: -2,
  //                   ),
  //                   BoxShadow(
  //                     color: Colors.black,
  //                     offset: Offset(6, 0),
  //                     blurRadius: 0,
  //                     spreadRadius: -2,
  //                   ),
  //                   BoxShadow(
  //                     color: Colors.black,
  //                     offset: Offset(6, 6),
  //                     blurRadius: 0,
  //                     spreadRadius: -2,
  //                   ),
  //                 ],
  //               ),
  //                 if (link != null && link.isNotEmpty)
  //              ElevatedButton(
  //               onPressed: () async {
  //                 final uri = Uri.parse(link);
  //                 if (await canLaunchUrl(uri)) {
  //                   await launchUrl(uri, mode: LaunchMode.externalApplication);
  //                 } else {
  //                   print('Could not launch $link');
  //                 }
  //               },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white, // shows container color
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 25,
  //                     vertical: 15,
  //                   ),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   'LINK',
  //                   style: TextStyle(color: Color(0xFF1FA7E3)),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 5),
  //         Text(
  //           'Description: $description',
  //           style: const TextStyle(color: Colors.black54),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildProjectCard({
    required String name,
    required String description,
    String? link, // make it nullable
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Name of Project: $name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (link != null && link.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(link);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      print('Could not launch $link');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'LINK',
                    style: TextStyle(color: Color(0xFF1FA7E3)),
                  ),
                ),
            ],
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
          text: '$label : ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Jost',
            color: Color(0xFF232323),
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Jost',
                color: Color(0xFF232323),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeFileItem(String fileName, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 20, color: Colors.blue[700])
                : null,
          ),
          const SizedBox(width: 12),

          // File name
          Text(fileName, style: const TextStyle(fontSize: 16)),

          const Spacer(),

          // More options icon
          Icon(Icons.more_vert, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildAIResumeBuilderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Resume Builder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _buildToolSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tool',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _buildToolItem('Manage the qualifications | Manage the qualifications'),
        const SizedBox(height: 8),
        _buildToolItem('Manage the qualifications | Manage the qualifications'),
      ],
    );
  }

  Widget _buildToolItem(String text) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }

  void _showResumeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resume'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResumeFileItem('Harish_Resume', false),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Click to Upload or drag and drop',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Max. File size: 1.2 MB)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDF | DOCX | > 3 MB',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Resume Builder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
