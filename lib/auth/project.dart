import 'package:flutter/material.dart';
import 'package:internappflutter/aboutYou/uploadProfilePic.dart';
import 'package:internappflutter/auth/skills.dart';
import 'package:internappflutter/models/usermodel.dart';

class ProjectsPage extends StatefulWidget {
  final UserExperience? userExperience;
  const ProjectsPage({Key? key, required this.userExperience})
    : super(key: key);

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final List<Map<String, String>> savedProjects = [];

  int filledFields = 0;
  final int totalFields = 3; // Project Name, Link, Description
  bool _isFormStarted = false; // Track if user started filling form

  bool get isFormComplete =>
      projectNameController.text.isNotEmpty &&
      linkController.text.isNotEmpty &&
      descController.text.isNotEmpty;

  bool get hasAnyText =>
      projectNameController.text.isNotEmpty ||
      linkController.text.isNotEmpty ||
      descController.text.isNotEmpty;

  void _updateProgress() {
    int count = 0;
    if (projectNameController.text.isNotEmpty) count++;
    if (linkController.text.isNotEmpty) count++;
    if (descController.text.isNotEmpty) count++;

    setState(() {
      filledFields = count;

      // If user started typing but form is incomplete, mark as started
      if (hasAnyText && !isFormComplete) {
        _isFormStarted = true;
      }

      // If form is complete, allow adding
      if (isFormComplete) {
        _isFormStarted = false;
      }

      // If all fields are empty, reset started state
      if (!hasAnyText) {
        _isFormStarted = false;
      }
    });
  }

  void _addProject() {
    if (!isFormComplete) return;

    setState(() {
      savedProjects.insert(0, {
        "projectName": projectNameController.text.trim(),
        "link": linkController.text.trim(),
        "desc": descController.text.trim(),
      });

      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearForm() {
    projectNameController.clear();
    linkController.clear();
    descController.clear();
    _isFormStarted = false;
    _updateProgress();
  }

  void _removeProject(int index) {
    setState(() {
      savedProjects.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showIncompleteFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Form'),
          content: const Text(
            'You have started filling the form but haven\'t completed all fields. Would you like to clear the form or continue editing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: const Text('Clear Form'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNext() {
    if (savedProjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one project before continuing.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // If form is started but not complete, show dialog
    if (_isFormStarted && !isFormComplete) {
      _showIncompleteFormDialog();
      return;
    }

    // Create UserProject model from the most recent project (if any)
    UserProject? userProject;

    if (widget.userExperience != null) {
      if (savedProjects.isNotEmpty) {
        final latestProject = savedProjects.first;
        userProject = UserProject.fromUserExperience(
          widget.userExperience!,
          projectName: latestProject['projectName']!,
          projectLink: latestProject['link']!,
          projectDescription: latestProject['desc']!,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadScreen(userProject: userProject),
          ),
        );
      } else {
        // Create a UserProject with empty project fields
        userProject = UserProject.fromUserExperience(
          widget.userExperience!,
          projectName: '',
          projectLink: '',
          projectDescription: '',
        );
      }

      // Debug print all fields
      print("---- Navigating to UploadScreen ----");
      print("User Details:");
      print("Name: ${userProject.name}");
      print("Email: ${userProject.email}");
      print("UID: ${userProject.uid}");
      print("Role: ${userProject.role}");
      print("College: ${userProject.collegeName}");
      print("University: ${userProject.university}");
      print("Degree: ${userProject.degree}");
      print("College Email: ${userProject.collegeEmailId}");
      print("Year: ${userProject.year}");
      print("Skills: ${userProject.userSkills}");
      print("Preferences: ${userProject.preferences}");
      print("Experience:");
      print("Organisation: ${userProject.organisation}");
      print("Position: ${userProject.position}");
      print("Date: ${userProject.date}");
      print("Description: ${userProject.description}");
      print("Project:");
      print("Project Name: ${userProject.projectName}");
      print("Project Link: ${userProject.projectLink}");
      print("Project Description: ${userProject.projectDescription}");
    }
  }

  @override
  void initState() {
    super.initState();
    projectNameController.addListener(_updateProgress);
    linkController.addListener(_updateProgress);
    descController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    projectNameController.dispose();
    linkController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = savedProjects.isNotEmpty
        ? 1.0
        : (filledFields / totalFields);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 244),
      body: SafeArea(
        child: Stack(
          children: [
            /// Background puzzle image (placeholder)
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 294,
                width: 261,
                child: Image.asset("assets/images/puzzle.png"),
              ),
            ),

            /// Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back button + progress bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_isFormStarted && !isFormComplete) {
                            _showIncompleteFormDialog();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey[300],
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Character and quote
                  Row(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 140,
                        child: Image.asset("assets/bear.gif", fit: BoxFit.fill),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 62,
                              width: double.infinity,
                              child: Image.asset(
                                "assets/Union.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            const Positioned(
                              top: 16,
                              left: 16,
                              right: 16, // allow text to wrap inside
                              child: Text(
                                "“Show off your projects 🚀”",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Title and description
                  const Text(
                    "Projects",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Flex your side hustles, hackathons, or college builds. Drop links & let recruiters see your work 🚀.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  /// Form validation warning
                  if (_isFormStarted && !isFormComplete)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        border: Border.all(color: Colors.orange, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please fill all fields to add project or clear the form.',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// Input Fields
                  _buildInputBox(
                    "Project Name *",
                    projectNameController,
                    "Write the name of the Project",
                  ),
                  const SizedBox(height: 16),

                  _buildInputBox(
                    "Link *",
                    linkController,
                    "Paste the link of your project",
                  ),
                  const SizedBox(height: 16),

                  /// Description Box
                  _buildDescriptionBox(),

                  const SizedBox(height: 24),

                  /// Action button for form
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isFormComplete ? _addProject : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormComplete
                            ? Colors.orange
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Saved Projects
                  if (savedProjects.isNotEmpty) ...[
                    Text(
                      "Saved Projects (${savedProjects.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(savedProjects.length, (index) {
                      final proj = savedProjects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: _boxDecoration(),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Project Name : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: proj['projectName']!),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Link : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: proj['link']!,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Description : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: proj['desc']!),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeProject(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],

                  /// Next button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB6A5FE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Extra space at bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build description box separately for better control
  Widget _buildDescriptionBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description *",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: _boxDecoration(),
          child: TextField(
            controller: descController,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: "Write about the project you built",
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  /// Reusable box decoration
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
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
    );
  }

  /// Reusable input box builder
  Widget _buildInputBox(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: _boxDecoration(),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
