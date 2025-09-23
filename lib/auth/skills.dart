import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Skills extends StatefulWidget {
  @override
  _SkillsState createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _jobsController = TextEditingController();
  int filledFields = 0;
  final int totalFields = 2;
  void updateProgress() {
    int count = 0;
    if (_skillsController.text.isNotEmpty) count++;
    if (_jobsController.text.isNotEmpty) count++;

    setState(() {
      filledFields = count;
    });
  }

  @override
  final List<String> allSkills = [
    "Adobe",
    "React",
    "Flutter",
    "Figma",
    "Tensor Flow",
    "Apple",
    "Banana",
    "Grapes",
    "Mango",
    "Orange",
    "Pineapple",
    "Strawberry",
    "Watermelon",
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
    _skillsController.addListener(
      updateProgress,
    ); //addListener → means: “Hey, whenever something inside this object changes, call this function.”
    _jobsController.addListener(updateProgress);
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
    if (!selectedSkills.contains(skill)) {
      setState(() {
        selectedSkills.add(skill);
      });
    }
    _skillsController.clear();
    filteredSkills = [];
  }

  void _removeSkill(String skill) {
    setState(() {
      selectedSkills.remove(skill);
    });
  }

  void _addJob(String job) {
    if (!selectedJobs.contains(job)) {
      setState(() {
        selectedJobs.add(job);
      });
    }
    _jobsController.clear();
    filteredJobs = [];
  }

  void _removeJob(String job) {
    setState(() {
      selectedJobs.remove(job);
    });
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
          width: 390,
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
            onSubmitted: (value) => onAdd(value),
          ),
        ),

        /// Selected Items (Pinned Chips)
        if (selectedItems.isNotEmpty)
          SizedBox(
            height: 80, // scrollable container
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                Wrap(
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
                          Text(
                            item.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
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
              ],
            ),
          ),

        if (filteredItems.isNotEmpty)
          Container(
            width: 390,
            height: 200,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredItems[index]),
                  onTap: () => onAdd(filteredItems[index]),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => RegisterPage()),
                    // );
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

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 164,
                  height: 205,
                  child: Image.asset('assets/aa.gif', fit: BoxFit.fill),
                ),
                Stack(
                  children: [
                    SizedBox(
                      height: 62,
                      width: 215,
                      child: Image.asset('assets/Union.png'),
                    ),
                    const Positioned(
                      top: 16,
                      left: 16,
                      child: SizedBox(
                        width: 215,
                        child: Text(
                          '“What can you slay at? 💪”.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Stack(
                children: [
                  Container(height: 475, width: 400),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 294,
                      width: 261,
                      child: Image.asset('assets/puzzle.png'),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'skills',
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          ),

                          _buildSearchSection(
                            hintText: "add your skills",
                            controller: _skillsController,
                            selectedItems: selectedSkills,
                            filteredItems: filteredSkills,
                            onChanged: _filterSkills,
                            onAdd: _addSkill,
                            onRemove: _removeSkill,
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            'Job Preference',
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          ),

                          _buildSearchSection(
                            hintText: "select your job",
                            controller: _jobsController,
                            selectedItems: selectedJobs,
                            filteredItems: filteredJobs,
                            onChanged: _filterJobs,
                            onAdd: _addJob,
                            onRemove: _removeJob,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            Container(
              width: 390,
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
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ExperiencePage()),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6A5FE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

