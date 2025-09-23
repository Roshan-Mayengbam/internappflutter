import 'package:flutter/material.dart';

class ProjectsPage extends StatefulWidget {
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

  bool get isAddEnabled =>
      projectNameController.text.isNotEmpty &&
      linkController.text.isNotEmpty &&
      descController.text.isNotEmpty;

  void _updateProgress() {
    int count = 0;
    if (projectNameController.text.isNotEmpty) count++;
    if (linkController.text.isNotEmpty) count++;
    if (descController.text.isNotEmpty) count++;

    setState(() {
      filledFields = count;
    });
  }

  void _addProject() {
    setState(() {
      savedProjects.insert(0, {
        "projectName": projectNameController.text,
        "link": linkController.text,
        "desc": descController.text,
      });

      projectNameController.clear();
      linkController.clear();
      descController.clear();
      _updateProgress();
    });
  }

  void _removeProject(int index) {
    setState(() {
      savedProjects.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    projectNameController.addListener(_updateProgress);
    linkController.addListener(_updateProgress);
    descController.addListener(_updateProgress);
  }

  @override
  Widget build(BuildContext context) {
    double progress = filledFields / totalFields;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 244),
      body: SafeArea(
        child: Stack(
          children: [
            /// 🔹 Puzzle image in background (bottom-right)
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 294,
                width: 261,
                child: Image.asset("assets/puzzle.png"),
              ),
            ),

            /// 🔹 Foreground content
            SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back button + progress bar
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

                  const SizedBox(height: 20),

                  /// Gif + Quote
                  Row(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 140,
                        child: Image.asset("assets/aa.gif", fit: BoxFit.fill),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          SizedBox(
                            height: 62,
                            width: 215,
                            child: Image.asset("assets/Union.png"),
                          ),
                          const Positioned(
                            top: 16,
                            left: 16,
                            child: SizedBox(
                              width: 215,
                              child: Text(
                                "“Show off your projects 🚀”",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  const Text(
                    "Projects",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Flex your side hustles, hackathons, or college builds. Drop links & let recruiters see your work 🚀.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// Input Fields
                  _buildInputBox(
                    "Project Name",
                    projectNameController,
                    "Write the name of the Project",
                  ),
                  const SizedBox(height: 12),

                  _buildInputBox(
                    "Link",
                    linkController,
                    "Paste the link of your project",
                  ),
                  const SizedBox(height: 12),

                  /// Description Box
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 120,
                    decoration: _boxDecoration(),
                    child: TextField(
                      controller: descController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: "Write about the project you built",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Saved Projects
                  if (savedProjects.isNotEmpty)
                    const Text(
                      "Saved Projects",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 12),

                  Column(
                    children: List.generate(savedProjects.length, (index) {
                      final proj = savedProjects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: _boxDecoration(),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Project Name : ${proj['projectName']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text("Link : ${proj['link']}"),
                                  Text("Description : ${proj['desc']}"),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeProject(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  /// Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isAddEnabled ? _addProject : null,
                          style: _buttonStyle(Colors.orange),
                          child: const Text("Add"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            // next page navigation
                          },
                          style: _buttonStyle(const Color(0xFFB6A5FE)),
                          child: const Text("Next"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// reusable box
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

  /// reusable input
  Widget _buildInputBox(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 54,
          decoration: _boxDecoration(),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  /// reusable button
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }
}
