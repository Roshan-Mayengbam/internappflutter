import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/screens/add_experience.dart';
import 'package:internappflutter/screens/add_project_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";
  late final String profilePicUrl;

  // controllers
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();
  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController degreeCtrl = TextEditingController();
  // final TextEditingController collegeEmailCtrl = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  List<String> skills = [];
  List<String> jobPreferences = [];
  List<Map<String, dynamic>> experiences = [];
  List<Map<String, dynamic>> projects = [];

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String uid = user.uid;
      String? idToken = await user.getIdToken();
      if (idToken == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/student/StudentDetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'studentId': uid}),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['user'];
          print(_userData);
          _populateFormData();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _populateFormData() {
    if (_userData == null) return;

    final profile = _userData!['profile'] ?? {};
    final education = _userData!['education'] ?? {};

    // Combine firstName and lastName into full name for display
    String firstName = profile['firstName'] ?? '';
    String lastName = profile['lastName'] ?? '';
    fullNameCtrl.text = profile['FullName'] ?? '';

    bioCtrl.text = profile['bio'] ?? 'Write about your bio';
    profilePicUrl = profile['profilePicture'];
    aboutCtrl.text = 'Write about yourself'; // Default value
    phoneCtrl.text = _userData!['phone'] ?? '+91 72645-05924';
    emailCtrl.text =
        _userData!['email'] ?? _auth.currentUser?.email ?? 'john@gmail.com';

    // Education data
    collegeCtrl.text = education['college'] ?? 'Sastra College';
    degreeCtrl.text = education['degree'] ?? 'Bachelor of Engineering';

    // Lists data
    skills = List<String>.from(
      (_userData!['user_skills'] as Map<String, dynamic>? ?? {}).keys,
    );
    jobPreferences = List<String>.from(_userData!['job_preference'] ?? []);
    experiences = List<Map<String, dynamic>>.from(
      _userData!['experience'] ?? [],
    );
    projects = List<Map<String, dynamic>>.from(_userData!['projects'] ?? []);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) return;
      String uid = user.uid;

      String? idToken = await user.getIdToken();
      if (idToken == null) return;

      // ✅ Profile data

      final profileData = {
        "FullName": fullNameCtrl.text.trim(),
        "bio": bioCtrl.text.trim(),
        "profilePicture": profilePicUrl.trim(),
        "about": aboutCtrl.text.trim(),
      };

      // ✅ Education data
      final educationData = {
        "college": collegeCtrl.text.trim(),
        // "universityType": universityTypeCtrl.text
        //     .trim(), // public/private/deemed
        "degree": degreeCtrl.text.trim(),
        // "collegeEmail": collegeEmailCtrl.text.trim(),
        // "yearOfPassing": int.tryParse(yearOfPassingCtrl.text.trim()) ?? 0,
      };

      // ✅ Skills → Map
      final Map<String, dynamic> formattedSkills = {};
      for (var skill in skills) {
        formattedSkills[skill] = {
          "level": "mid",
        }; // you can change "mid" dynamically
      }

      // ✅ Experience (List of Maps)
      final List<Map<String, dynamic>> formattedExperience = experiences.map((
        exp,
      ) {
        return {
          "nameOfOrg": exp["nameOfOrg"],
          "position": exp["position"],
          "timeline": exp["timeline"],
          "description": exp["description"],
        };
      }).toList();

      // ✅ Projects (List of Maps)
      final List<Map<String, dynamic>> formattedProjects = projects.map((proj) {
        return {
          "projectName": proj["projectName"],
          "link": proj["link"],
          "description": proj["description"],
        };
      }).toList();

      // ✅ Final update body
      final updateData = {
        "FullName": fullNameCtrl.text.trim(),
        "firebaseId": uid, // this ties student to Firebase
        "email": emailCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "profile": profileData,
        "education": educationData,
        "user_skills": formattedSkills,
        "job_preference": jobPreferences, // must be List<String>
        "experience": formattedExperience,
        "projects": formattedProjects,
      };

      print("Sending update data: ${json.encode(updateData)}");

      final response = await http.put(
        Uri.parse('$baseUrl/student/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: json.encode(updateData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${errorData['message'] ?? response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Future<void> _saveSkills() async {
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user == null) return;

  //     String? idToken = await user.getIdToken();
  //     if (idToken == null) return;

  //     // Add each new skill using the addSkill endpoint
  //     for (final skill in skills) {
  //       final response = await http.post(
  //         Uri.parse('$baseUrl/student/addSkill'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $idToken',
  //         },
  //         body: json.encode({'skillName': skill}),
  //       );

  //       if (response.statusCode != 200) {
  //         print('Failed to add skill: $skill');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error saving skills: $e');
  //   }
  // }

  Future<void> _addSkill(String skillName) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String uid = user.uid;
      String? idToken = await user.getIdToken();
      if (idToken == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/student/addSkills'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'studentId': uid, 'skillName': skillName}),
      );

      if (response.statusCode == 200) {
        setState(() {
          skills.add(skillName);
        });
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add skill: ${errorData['message']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding skill: ${e.toString()}')),
      );
    }
  }

  void _removeSkill(int index) {
    final skillToRemove = skills[index];
    setState(() {
      skills.removeAt(index);
    });
    // Note: You might want to implement a removeSkill endpoint in your backend
  }

  void _addExperience() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExperienceScreen()),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        setState(() {
          experiences.add(value);
        });
        // Note: You might need to save experiences to backend separately
      }
    });
  }

  void _editExperience(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddExperienceScreen(experience: experiences[index]),
      ),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        setState(() {
          experiences[index] = value;
        });
      }
    });
  }

  void _deleteExperience(int index) {
    setState(() {
      experiences.removeAt(index);
    });
  }

  void _addProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen()),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        setState(() {
          projects.add(value);
        });
        // Note: You might need to save projects to backend separately
      }
    });
  }

  void _editProject(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProjectScreen(project: projects[index]),
      ),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        setState(() {
          projects[index] = value;
        });
      }
    });
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // top profile picture
          ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 60,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),

          // everything in ONE draggable sheet
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // full name
                      _buildTextField('Full Name', fullNameCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Phone Number', phoneCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Email', emailCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Bio', bioCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('About', aboutCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('College Name', collegeCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Degree', degreeCtrl),

                      // const SizedBox(height: 15),
                      // _buildTextField('College Email ID', collegeEmailCtrl),
                      const Divider(height: 40),

                      // Skills Section
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                        ),
                      ),
                      const SizedBox(height: 10),

                      // big input box for skill
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                        ),
                        child: TextField(
                          controller: skillController,
                          decoration: InputDecoration(
                            hintText: 'Add Your Skills',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _addSkill(value.trim());
                              skillController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Show skill chips with red delete
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: skills
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildChip(
                                entry.value,
                                onDelete: () => _removeSkill(entry.key),
                                deleteColor: Colors.red,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 30),

                      // Job Preference input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                        ),
                        child: TextField(
                          controller: jobController,
                          decoration: InputDecoration(
                            hintText: 'Select Your Job Preference',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                jobPreferences.add(value.trim());
                                jobController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Show job chips with red delete
                      Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: jobPreferences
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildChip(
                                entry.value,
                                onDelete: () {
                                  setState(() {
                                    jobPreferences.removeAt(entry.key);
                                  });
                                },
                                deleteColor: Colors.red,
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Experience',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _addExperience,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5B967),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dynamic Experience Cards
                      ...experiences.asMap().entries.map((entry) {
                        final experience = entry.value;
                        return _buildExperienceCard(
                          organization:
                              experience['nameOfOrg'] ?? 'Organization',
                          position: experience['position'] ?? 'Position',
                          timeline: experience['timeline'] ?? 'Timeline',
                          description:
                              experience['description'] ?? 'Description',
                          onEdit: () => _editExperience(entry.key),
                          onDelete: () => _deleteExperience(entry.key),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Projects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _addProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5B967),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dynamic Project Cards
                      ...projects.asMap().entries.map((entry) {
                        final project = entry.value;
                        return _buildProjectCard(
                          projectName: project['projectName'] ?? 'Project Name',
                          link: project['link'] ?? 'Link',
                          description: project['description'] ?? 'Description',
                          onEdit: () => _editProject(entry.key),
                          onDelete: () => _deleteProject(entry.key),
                        );
                      }).toList(),

                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF090909),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
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
                          ),
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF090909),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.transparent,
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontFamily: 'Jost',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontFamily: 'Jost',
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
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
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    String label, {
    required VoidCallback onDelete,
    Color deleteColor = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              fontFamily: GoogleFonts.jost().fontFamily,
              color: const Color(0xFF1FA7E3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 25, color: deleteColor),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard({
    required String organization,
    required String position,
    required String timeline,
    required String description,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Organization: $organization',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('Position: $position', style: TextStyle(fontFamily: 'Jost')),
          Text('Timeline: $timeline', style: TextStyle(fontFamily: 'Jost')),
          const SizedBox(height: 8),
          Text(
            'Description: $description',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String projectName,
    required String link,
    required String description,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Project: $projectName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('Link: $link', style: TextStyle(fontFamily: 'Jost')),
          const SizedBox(height: 8),
          Text(
            'Description: $description',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }
}
