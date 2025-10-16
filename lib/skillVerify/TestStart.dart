import 'package:flutter/material.dart';
import 'package:internappflutter/skillVerify/test1.dart';

class TestStart extends StatefulWidget {
  final String selectedSkill;
  const TestStart({super.key, required this.selectedSkill});

  @override
  State<TestStart> createState() => _TestStartState();
}

List<String> levels = ["Beginner", "Intermediate", "Advanced"];

class _TestStartState extends State<TestStart> {
  String currentOption = levels[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEADC30),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 0,
                          spreadRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${widget.selectedSkill} Test",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 44), // Balance the back button
                ],
              ),
            ),

            Divider(color: Colors.black, thickness: 2, height: 0),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      // Title Image
                      Image.asset(
                        'assets/text1.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: 30),

                      // Bear GIF
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/bear.gif',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Level Selection Text
                      Text(
                        'Choose your level:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Level Options
                      ...levels.asMap().entries.map((entry) {
                        int index = entry.key;
                        String level = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: LevelOption(
                            level: level,
                            isSelected: currentOption == level,
                            onTap: () {
                              setState(() {
                                currentOption = level;
                              });
                            },
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => test1(
                          selectedSkill: widget.selectedSkill,
                          selectedLevel: currentOption,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('START TEST'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelOption extends StatelessWidget {
  final String level;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelOption({
    Key? key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black : Colors.transparent,
              spreadRadius: 2,
              blurRadius: 0,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                color: isSelected ? Colors.black : Colors.white,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16),
            Text(
              level.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
