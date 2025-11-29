import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/screens/add_experience.dart';
import 'package:internappflutter/screens/add_project_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";
  // final String baseUrl2 = "http://10.129.135.157:3000";

  String profilePicUrl = '';

  // controllers
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();
  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController degreeCtrl = TextEditingController();
  final TextEditingController collegeEmailCtrl = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController yearOfPassingCtrl = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  List<String> skills = [];
  List<String> jobPreferences = [];
  List<Map<String, dynamic>> experiences = [];
  List<Map<String, dynamic>> projects = [];
  final ImagePicker _picker = ImagePicker();

  // Skills related
  List<String> _allSkills = [];
  bool _skillsLoaded = false;
  final TextEditingController _skillsController = TextEditingController();
  List<String> selectedSkills = [];
  List<String> filteredSkills = [];

  // Add these for Job Preferences
  List<String> _allJobs = [];
  bool _jobsLoaded = false;
  final TextEditingController _jobsController = TextEditingController();
  List<String> selectedJobs = [];
  List<String> filteredJobs = [];

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSkillsFromJson();
    _loadJobsFromJson();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ - Request granular media permissions
          await [Permission.photos, Permission.camera].request();
        } else if (androidInfo.version.sdkInt >= 30) {
          // Android 11-12
          await [Permission.storage, Permission.camera].request();
        } else {
          // Android 10 and below
          await [Permission.storage, Permission.camera].request();
        }
      } catch (e) {
        print('Error requesting permissions: $e');
      }
    }
  }

  // ✅ CHECK PERMISSIONS
  Future<bool> _checkPermission(Permission permission) async {
    if (Platform.isIOS) return true; // iOS handles permissions differently

    final status = await permission.status;
    return status.isGranted;
  }

  // ✅ SHOW PERMISSION DIALOG
  Future<bool?> _showPermissionDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontFamily: 'Jost')),
          content: Text(message, style: const TextStyle(fontFamily: 'Jost')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  // ✅ SHOW PERMISSION DENIED SNACKBAR
  void _showPermissionDeniedSnackBar(String permissionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionType permission denied'),
        backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  /// Alternative: Pick from camera
  Future<void> _pickImageSource() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jost',
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1FA7E3),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1FA7E3)),
                title: const Text(
                  'Camera',
                  style: TextStyle(fontFamily: 'Jost'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method
  Future<List<String>> _loadSkillsFromJson() async {
    if (_skillsLoaded) return _allSkills;

    try {
      final String response = await rootBundle.loadString(
        'assets/userskills.json',
      );
      final List<dynamic> data = json.decode(response);
      _allSkills = data.cast<String>();
      _skillsLoaded = true;
      return _allSkills;
    } catch (e) {
      print('Error loading skills: $e');
      return [];
    }
  }

  // Add this method after _loadSkillsFromJson
  Future<List<String>> _loadJobsFromJson() async {
    if (_jobsLoaded) return _allJobs;

    try {
      final String response = await rootBundle.loadString(
        'assets/jobPeference.json', // Note: Check your spelling - it's "Peference" not "Preference"
      );
      final List<dynamic> data = json.decode(response);
      _allJobs = data.cast<String>();
      _jobsLoaded = true;
      return _allJobs;
    } catch (e) {
      print('Error loading jobs: $e');
      return [];
    }
  }

  /// Pick and upload image from specified source
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Check appropriate permission based on source
      Permission requiredPermission;
      String permissionName;

      if (source == ImageSource.camera) {
        requiredPermission = Permission.camera;
        permissionName = 'Camera';
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            requiredPermission = Permission.photos;
          } else {
            requiredPermission = Permission.storage;
          }
        } else {
          requiredPermission = Permission.photos;
        }
        permissionName = 'Gallery';
      }

      // Check if permission is granted
      bool hasPermission = await _checkPermission(requiredPermission);

      if (!hasPermission) {
        // Ask user if they want to grant permission
        bool? shouldRequest = await _showPermissionDialog(
          '$permissionName Access',
          'This app needs $permissionName permission to ${source == ImageSource.camera ? 'take' : 'select'} photos for your profile picture.',
        );

        if (shouldRequest == true) {
          final status = await requiredPermission.request();
          hasPermission = status.isGranted;
        }

        if (!hasPermission) {
          _showPermissionDeniedSnackBar(permissionName);
          return;
        }
      }

      print("1. Starting image upload process...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      print("2. Image picked: ${pickedFile?.path}");

      if (pickedFile == null) {
        Navigator.pop(context);
        return;
      }

      final User? user = _auth.currentUser;
      print("3. User: ${user?.uid}");

      if (user == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final String uid = user.uid;
      final String? idToken = await user.getIdToken();
      print("4. ID Token obtained: ${idToken != null}");

      if (idToken == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get auth token')),
        );
        return;
      }

      // Upload to Firebase Storage
      final File imageFile = File(pickedFile.path);
      final String fileName =
          'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      print("5. Uploading to Firebase Storage...");
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();
      print("6. Firebase Storage URL: $downloadURL");

      // Send to backend
      print("7. Sending to backend: $baseUrl/student/profile-photo");
      final response = await http.put(
        Uri.parse('$baseUrl/student/profile-photo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'profileUrl': downloadURL}),
      );

      print("8. Backend response status: ${response.statusCode}");
      print("9. Backend response body: ${response.body}");

      Navigator.pop(context);

      if (response.statusCode == 200) {
        setState(() {
          profilePicUrl = downloadURL;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        print('Upload failed: ${errorData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${errorData['message'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error uploading image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
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
    aboutController.text = profile['about'] ?? '';
    profilePicUrl = profile['profilePicture'];
    aboutCtrl.text = 'Write about yourself'; // Default value
    phoneCtrl.text = _userData!['phone'] ?? '+91 72645-05924';
    emailCtrl.text =
        _userData!['email'] ?? _auth.currentUser?.email ?? 'No Email';

    // Education data
    collegeCtrl.text = education['college'] ?? '';
    degreeCtrl.text = education['degree'] ?? '';
    collegeEmailCtrl.text = education['collegeEmail'] ?? '';
    yearOfPassingCtrl.text = education['yearOfPassing']?.toString() ?? '';

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

      // ✅ Profile data - ONLY include fields we want to update
      final Map<String, dynamic> profileData = {
        "FullName": fullNameCtrl.text.trim(),
        "bio": bioCtrl.text.trim(),
        "about": aboutController.text.trim(),
      };

      // Only add profilePicture if it exists
      if (profilePicUrl.trim().isNotEmpty) {
        profileData["profilePicture"] = profilePicUrl.trim();
      }
      // DON'T send resume and resumeName here

      // ✅ Education data
      final Map<String, dynamic> educationData = {
        "college": collegeCtrl.text.trim(),
        "degree": degreeCtrl.text.trim(),
      };

      if (collegeEmailCtrl.text.trim().isNotEmpty) {
        educationData["collegeEmail"] = collegeEmailCtrl.text.trim();
      }

      final yearText = yearOfPassingCtrl.text.trim();
      if (yearText.isNotEmpty) {
        final year = int.tryParse(yearText);
        if (year != null) {
          educationData["yearOfPassing"] = year; // Send as int, not string
        }
      }

      // ✅ Skills → Map
      final Map<String, dynamic> formattedSkills = {};
      for (var skill in skills) {
        formattedSkills[skill] = {"level": "unverified"};
      }

      // ✅ Experience
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

      // ✅ Projects
      final List<Map<String, dynamic>> formattedProjects = projects.map((proj) {
        return {
          "projectName": proj["projectName"],
          "link": proj["link"],
          "description": proj["description"],
        };
      }).toList();

      // ✅ Final update body
      final updateData = {
        "phone": phoneCtrl.text.trim(),
        "profile": profileData,
        "education": educationData,
        "user_skills": formattedSkills,
        "job_preference": jobPreferences,
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

  void _removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
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

  // Add this method to load skills from JSON

  // Add this method to filter skills
  void _filterSkills(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSkills = [];
      });
      return;
    }

    setState(() {
      filteredSkills = _allSkills
          .where(
            (skill) =>
                skill.toLowerCase().contains(query.toLowerCase()) &&
                !skills.contains(skill),
          )
          .toList();
    });
  }

  // Update your _addSkill method to work with the new system
  void _addSkillFromSearch(String skillName) {
    _addSkill(skillName);
    _skillsController.clear();
    setState(() {
      filteredSkills = [];
    });
  }

  // Update your _removeSkill to accept String instead of int
  void _removeSkillByName(String skillName) {
    setState(() {
      skills.remove(skillName);
    });
  }

  // Add this method to filter jobs
  void _filterJobs(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredJobs = [];
      });
      return;
    }

    setState(() {
      filteredJobs = _allJobs
          .where(
            (job) =>
                job.toLowerCase().contains(query.toLowerCase()) &&
                !jobPreferences.contains(job),
          )
          .toList();
    });
  }

  // Method to add job from search
  void _addJob(String jobName) {
    setState(() {
      jobPreferences.add(jobName);
    });
    _jobsController.clear();
    setState(() {
      filteredJobs = [];
    });
  }

  // Method to remove job
  void _removeJob(String jobName) {
    setState(() {
      jobPreferences.remove(jobName);
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
                child: // Replace the profile picture section in your build method with this:
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 60,
                        backgroundImage: profilePicUrl.isNotEmpty
                            ? NetworkImage(profilePicUrl)
                            : null,
                        child: profilePicUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
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
                          child: InkWell(
                            onTap: _pickImageSource,
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontFamily: 'Jost',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
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
                              controller: emailCtrl,
                              enabled: false,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField('Bio', bioCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('About', aboutController),
                      const SizedBox(height: 15),
                      _buildTextField('College Name', collegeCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Degree', degreeCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Year of graduation', yearOfPassingCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('College Email ID', collegeEmailCtrl),

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

                      _buildSearchSection(
                        hintText: "Add your skills",
                        controller: _skillsController,
                        // selectedItems: skills, //
                        filteredItems: filteredSkills,
                        onChanged: _filterSkills,
                        onRemove: _removeSkill,
                        onAdd: _addSkillFromSearch,
                        selectedItems: [],
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
                                onDelete: () =>
                                    _removeSkill(entry.key as String),
                                deleteColor: Colors.red,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 30),

                      // Job Preference input
                      // Job Preference input - REMOVE Expanded wrapper
                      _buildSearchSection(
                        hintText: "Select your job preference",
                        controller: _jobsController,
                        selectedItems: selectedJobs,
                        filteredItems: filteredJobs,
                        onChanged: _filterJobs,
                        onAdd: _addJob,
                        onRemove: _removeJob,
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
                          const Flexible(
                            child: Text(
                              'Experience',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addExperience,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5B967),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, // Reduced from 20
                                vertical: 10, // Reduced from 12
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
                          const Flexible(
                            child: Text(
                              'Projects',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5B967),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, // Reduced from 20
                                vertical: 10, // Reduced from 12
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
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.jost().fontFamily,
                color: const Color(0xFF1FA7E3),
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildSearchSection({
    required String hintText,
    required TextEditingController controller,
    required List<String> selectedItems,
    required List<String> filteredItems,
    required Function(String) onChanged,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Search Field
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 390),
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                onAdd(value.trim());
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        /// Selected Items (Pinned Chips)
        if (selectedItems.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 120, maxWidth: 390),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            item.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        /// Filtered Results Dropdown
        if (filteredItems.isNotEmpty)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 390, maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredItems[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => onAdd(filteredItems[index]),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}
