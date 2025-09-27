import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/auth/experience.dart';
import 'package:internappflutter/models/usermodel.dart';

class Skills extends StatefulWidget {
  final ExtendedUserModel? extendedUserModel;

  const Skills({Key? key, required this.extendedUserModel}) : super(key: key);

  @override
  _SkillsState createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _jobsController = TextEditingController();
  int filledFields = 0;
  final int totalFields = 2;

  final List<String> allSkills = [
    "Adobe",
    "React",
    "Flutter",
    "Figma",
    "Tensor Flow",
    "Python",
    "JavaScript",
    "Java",
    "Swift",
    "Kotlin",
    "HTML/CSS",
    "Node.js",
    "MongoDB",
  ];

  final List<String> allJobs = [
    "Software Developer",
    "UI/UX Designer",
    "Data Scientist",
    "Mobile App Developer",
    "Web Developer",
    "Product Manager",
    "AI Engineer",
    "Graphic Designer",
    "System Analyst",
    "Database Admin",
  ];

  List<String> filteredSkills = [];
  List<String> selectedSkills = [];

  List<String> filteredJobs = [];
  List<String> selectedJobs = [];

  @override
  void initState() {
    super.initState();
    filteredSkills = [];
    filteredJobs = [];
    _skillsController.addListener(updateProgress);
    _jobsController.addListener(updateProgress);
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _jobsController.dispose();
    super.dispose();
  }

  void updateProgress() {
    int count = 0;
    if (selectedSkills.isNotEmpty) count++;
    if (selectedJobs.isNotEmpty) count++;

    setState(() {
      filledFields = count;
    });
  }

  void _filterSkills(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSkills = [];
      } else {
        filteredSkills = allSkills
            .where(
              (item) =>
                  item.toLowerCase().contains(query.toLowerCase()) &&
                  !selectedSkills.contains(item),
            )
            .toList();
      }
    });
  }

  void _filterJobs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredJobs = [];
      } else {
        filteredJobs = allJobs
            .where(
              (item) =>
                  item.toLowerCase().contains(query.toLowerCase()) &&
                  !selectedJobs.contains(item),
            )
            .toList();
      }
    });
  }

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
      setState(() {
        selectedSkills.add(skill);
        filteredSkills = [];
      });
      _skillsController.clear();
      updateProgress();
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      selectedSkills.remove(skill);
    });
    updateProgress();
  }

  void _addJob(String job) {
    if (job.isNotEmpty && !selectedJobs.contains(job)) {
      setState(() {
        selectedJobs.add(job);
        filteredJobs = [];
      });
      _jobsController.clear();
      updateProgress();
    }
  }

  void _removeJob(String job) {
    setState(() {
      selectedJobs.remove(job);
    });
    updateProgress();
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

  @override
  Widget build(BuildContext context) {
    double progress = filledFields / totalFields;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 244),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 394,
                width: 261,
                child: Image.asset("assets/images/puzzle.png"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// Progress Bar Row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
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

                  const SizedBox(height: 24),

                  /// Character and Speech Bubble
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 150,
                        child: Image.asset(
                          'assets/bear.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/Union.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                              Text(
                                '"What can you slay at? 💪"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSearchSection(
                            hintText: "Add your skills",
                            controller: _skillsController,
                            selectedItems: selectedSkills,
                            filteredItems: filteredSkills,
                            onChanged: _filterSkills,
                            onAdd: _addSkill,
                            onRemove: _removeSkill,
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            'Job Preference',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSearchSection(
                            hintText: "Select your job preference",
                            controller: _jobsController,
                            selectedItems: selectedJobs,
                            filteredItems: filteredJobs,
                            onChanged: _filterJobs,
                            onAdd: _addJob,
                            onRemove: _removeJob,
                          ),

                          const SizedBox(height: 100), // Space for the button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: (selectedSkills.isNotEmpty && selectedJobs.isNotEmpty)
                ? () {
                    // Convert ExtendedUserModel -> UserWithSkills
                    // Check if the extendedUserModel is actually a CourseRange with year info
                    String yearValue = '';
                    if (widget.extendedUserModel is CourseRange) {
                      final courseRange =
                          widget.extendedUserModel as CourseRange;
                      yearValue = courseRange.year;
                      print("Found CourseRange with year: $yearValue");
                    }

                    final userWithSkills = UserWithSkills.fromExtended(
                      widget.extendedUserModel!,
                      userSkills: selectedSkills,
                      preferences: selectedJobs,
                      year:
                          yearValue, // Now using the actual year from CourseRange
                    );

                    // Debug print everything - FIXED TO SHOW CORRECT SKILLS
                    print("---- UserWithSkills ----");
                    print("Name: ${userWithSkills.name}");
                    print("Email: ${userWithSkills.email}");
                    print("Phone: ${userWithSkills.phone}");
                    print("UID: ${userWithSkills.uid}");
                    print("Role: ${userWithSkills.role}");
                    print("College: ${userWithSkills.collegeName}");
                    print("University: ${userWithSkills.university}");
                    print("Degree: ${userWithSkills.degree}");
                    print("College Email: ${userWithSkills.collegeEmailId}");
                    print("Year: ${userWithSkills.year}");
                    print(
                      "Inherited Skills (from ExtendedUserModel): ${userWithSkills.skills}",
                    );
                    print(
                      "User Selected Skills: ${userWithSkills.userSkills}",
                    ); // FIXED: Show userSkills instead of skills
                    print("Job Preferences: ${userWithSkills.preferences}");
                    print("Jobs (inherited): ${userWithSkills.jobs}");

                    // Navigate to ExperiencePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExperiencePage(userWithSkills: userWithSkills),
                      ),
                    );
                  }
                : null,

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (selectedSkills.isNotEmpty && selectedJobs.isNotEmpty)
                  ? const Color(0xFFB6A5FE)
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('NEXT'),
          ),
        ),
      ),
    );
  }
}
