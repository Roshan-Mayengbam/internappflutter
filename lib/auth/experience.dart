import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/auth/project.dart';
import 'package:internappflutter/models/usermodel.dart';

class ExperiencePage extends StatefulWidget {
  final UserWithSkills? userWithSkills;

  const ExperiencePage({Key? key, required this.userWithSkills})
    : super(key: key);

  @override
  _ExperiencePageState createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  final TextEditingController orgController = TextEditingController();
  final TextEditingController posController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final List<Map<String, String>> savedExperiences = [];

  int filledFields = 0;
  final int totalFields = 4; // org, pos, time, desc
  bool _isFormStarted = false; // Track if user started filling form

  bool get isFormComplete =>
      orgController.text.isNotEmpty &&
      posController.text.isNotEmpty &&
      timeController.text.isNotEmpty &&
      descController.text.isNotEmpty;

  bool get hasAnyText =>
      orgController.text.isNotEmpty ||
      posController.text.isNotEmpty ||
      timeController.text.isNotEmpty ||
      descController.text.isNotEmpty;

  void _updateProgress() {
    int count = 0;
    if (orgController.text.isNotEmpty) count++;
    if (posController.text.isNotEmpty) count++;
    if (timeController.text.isNotEmpty) count++;
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

  void _addExperience() {
    if (!isFormComplete) return;

    setState(() {
      savedExperiences.insert(0, {
        "org": orgController.text.trim(),
        "pos": posController.text.trim(),
        "time": timeController.text.trim(),
        "desc": descController.text.trim(),
      });

      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Experience added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearForm() {
    orgController.clear();
    posController.clear();
    timeController.clear();
    descController.clear();
    _isFormStarted = false;
    _updateProgress();
  }

  void _removeExperience(int index) {
    setState(() {
      savedExperiences.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Experience removed'),
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
    // If form is started but not complete, show dialog
    if (_isFormStarted && !isFormComplete) {
      _showIncompleteFormDialog();
      return;
    }

    // Create UserExperience model from the most recent experience (if any)
    UserExperience? userExperience;

    if (widget.userWithSkills != null) {
      if (savedExperiences.isNotEmpty) {
        final latestExp = savedExperiences.first;
        userExperience = UserExperience.fromUserWithSkills(
          widget.userWithSkills!,
          organisation: latestExp['org']!,
          position: latestExp['pos']!,
          date: latestExp['time']!,
          description: latestExp['desc']!,
        );
      } else {
        // Create a UserExperience with empty experience fields
        userExperience = UserExperience.fromUserWithSkills(
          widget.userWithSkills!,
          organisation: '',
          position: '',
          date: '',
          description: '',
        );
      }

      // ✅ Print everything
      if (kDebugMode) print("---- Navigating to ProjectsPage ----");
      if (kDebugMode) print("Total Experiences: ${savedExperiences.length}");
      if (savedExperiences.isNotEmpty) {
        if (kDebugMode) print("Latest Experience: ${savedExperiences.first}");
      }
      if (kDebugMode) print("---- UserExperience Details ----");
      if (kDebugMode) print("Name: ${userExperience.name}");
      if (kDebugMode) print("Email: ${userExperience.email}");
      if (kDebugMode) print("Phone: ${userExperience.phone}");
      if (kDebugMode) print("UID: ${userExperience.uid}");
      if (kDebugMode) print("Role: ${userExperience.role}");
      if (kDebugMode) print("College: ${userExperience.collegeName}");
      if (kDebugMode) print("University: ${userExperience.university}");
      if (kDebugMode) print("Degree: ${userExperience.degree}");
      if (kDebugMode) print("College Email: ${userExperience.collegeEmailId}");
      if (kDebugMode) print("Year: ${userExperience.year}");
      if (kDebugMode) print("Skills: ${userExperience.userSkills}");
      if (kDebugMode) print("Preferences/Jobs: ${userExperience.preferences}");
      if (kDebugMode) print("Organisation: ${userExperience.organisation}");
      if (kDebugMode) print("Position: ${userExperience.position}");
      if (kDebugMode) print("Date: ${userExperience.date}");
      if (kDebugMode) print("Description: ${userExperience.description}");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsPage(userExperience: userExperience),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    orgController.addListener(_updateProgress);
    posController.addListener(_updateProgress);
    timeController.addListener(_updateProgress);
    descController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    orgController.dispose();
    posController.dispose();
    timeController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = savedExperiences.isNotEmpty
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
                        // <-- changed here
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 62,
                              width:
                                  double.infinity, // takes all available width
                              child: Image.asset(
                                "assets/Union.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            const Positioned(
                              top: 16,
                              left: 16,
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  "“Any XP to flex? 👩‍💻”",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
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
                    "Experience",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Internships, part-time jobs, freelance gigs — every hustle counts.",
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
                              'Please fill all fields to add experience or clear the form.',
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
                    "Name of organization *",
                    orgController,
                    "Write the name of the organisation",
                  ),
                  const SizedBox(height: 16),

                  _buildInputBox(
                    "Position *",
                    posController,
                    "Which position did you work on",
                  ),
                  const SizedBox(height: 16),

                  _buildInputBox("Timeline *", timeController, "Date"),
                  const SizedBox(height: 16),

                  /// Description Box
                  _buildDescriptionBox(),

                  const SizedBox(height: 24),

                  /// Action buttons for form
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                            onPressed: isFormComplete ? _addExperience : () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,

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
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// Saved Experiences
                  if (savedExperiences.isNotEmpty) ...[
                    const Text(
                      "Saved Experience",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(savedExperiences.length, (index) {
                      final exp = savedExperiences[index];
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
                                          text: "Name of Organization : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: exp['org']!),
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
                                          text: "Position : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: exp['pos']!),
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
                                          text: "Timeline : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: exp['time']!),
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
                                        TextSpan(text: exp['desc']!),
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
                                onTap: () => _removeExperience(index),
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
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _navigateToNext,
                      style: _buttonStyle(const Color(0xFFB6A5FE)),
                      child: const Text(
                        "NEXT",
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
          "Description",
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
              hintText: "Write about the experience you had",
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color.fromARGB(255, 227, 214, 214),
        width: 1,
      ),
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

  /// Reusable button style
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }
}
