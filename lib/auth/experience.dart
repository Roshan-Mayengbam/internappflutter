import 'package:flutter/material.dart';
class ExperiencePage extends StatefulWidget {
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

  bool get isAddEnabled =>
      orgController.text.isNotEmpty &&
      posController.text.isNotEmpty &&
      timeController.text.isNotEmpty &&
      descController.text.isNotEmpty;

  void _updateProgress() {
    int count = 0;
    if (orgController.text.isNotEmpty) count++;
    if (posController.text.isNotEmpty) count++;
    if (timeController.text.isNotEmpty) count++;
    if (descController.text.isNotEmpty) count++;

    setState(() {
      filledFields = count;
    });
  }

  void _addExperience() {
    setState(() {
      savedExperiences.insert(0, {
        "org": orgController.text,
        "pos": posController.text,
        "time": timeController.text,
        "desc": descController.text,
      });

      orgController.clear();
      posController.clear();
      timeController.clear();
      descController.clear();
      _updateProgress();
    });
  }

  void _removeExperience(int index) {
    setState(() {
      savedExperiences.removeAt(index);
    });
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

            /// 🔹 Foreground content (scrollable)
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  const Text(
                    "Experience",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Internships, part-time jobs, freelance gigs — every hustle counts.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// Input Fields
                  _buildInputBox(
                    "Name of organization",
                    orgController,
                    "Write the name of the organisation",
                  ),
                  const SizedBox(height: 12),

                  _buildInputBox(
                    "Position",
                    posController,
                    "Which position did you worked on",
                  ),
                  const SizedBox(height: 12),

                  _buildInputBox("Timeline", timeController, "Date"),
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
                        hintText: "Write about the experience you had",
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

                  /// Saved Experience
                  if (savedExperiences.isNotEmpty)
                    const Text(
                      "Saved Experience",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 12),

                  Column(
                    children: List.generate(savedExperiences.length, (index) {
                      final exp = savedExperiences[index];
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
                                    "Name of Organization : ${exp['org']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text("Position : ${exp['pos']}"),
                                  Text("Timeline : ${exp['time']}"),
                                  Text("Description : ${exp['desc']}"),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeExperience(index),
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
                          onPressed: isAddEnabled ? _addExperience : null,
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ProjectsPage(),
                              // ),
                            //);
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
