import 'package:flutter/material.dart';
import 'package:internappflutter/skillVerify/test1.dart';

class TestStart extends StatefulWidget {
  final String selectedSkill;
  final String UserSkillLevel;
  const TestStart({
    super.key,
    required this.selectedSkill,
    required this.UserSkillLevel,
  });

  @override
  State<TestStart> createState() => _TestStartState();
}

List<String> levels = ["Beginner", "Intermediate", "Advanced"];

class _TestStartState extends State<TestStart> {
  String currentOption = levels[0];

  @override
  void initState() {
    super.initState();
    print(widget.UserSkillLevel);
    print(widget.selectedSkill);

    // Set default selected option based on user's current level
    if (widget.UserSkillLevel.toLowerCase() == 'beginner') {
      currentOption = levels[1]; // Intermediate
    } else if (widget.UserSkillLevel.toLowerCase() == 'intermediate' ||
        widget.UserSkillLevel.toLowerCase() == 'mid') {
      currentOption = levels[2]; // Advanced
    } else {
      currentOption = levels[0]; // Beginner for unverified
    }
  }

  // Function to check if a level should be disabled
  bool isLevelDisabled(String level) {
    String userLevel = widget.UserSkillLevel.toLowerCase();

    // If unverified, all levels are available
    if (userLevel == 'unverified') {
      return false;
    }

    // If beginner, disable beginner level
    if (userLevel == 'beginner' && level.toLowerCase() == 'beginner') {
      return true;
    }

    // If intermediate/mid, disable beginner and intermediate levels
    if ((userLevel == 'intermediate' || userLevel == 'mid') &&
        (level.toLowerCase() == 'beginner' ||
            level.toLowerCase() == 'intermediate')) {
      return true;
    }

    // If advanced, disable all levels (they've already completed all)
    if (userLevel == 'advanced') {
      return true;
    }

    return false;
  }

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

                      // Current Level Badge
                      if (widget.UserSkillLevel.toLowerCase() != 'unverified')
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'Current Level: ${widget.UserSkillLevel.toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
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
                        widget.UserSkillLevel.toLowerCase() == 'unverified'
                            ? 'Choose your level:'
                            : 'Choose next level to unlock:',
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
                        bool disabled = isLevelDisabled(level);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: LevelOption(
                            level: level,
                            isSelected: currentOption == level,
                            isDisabled: disabled,
                            onTap: disabled
                                ? () {} // Do nothing if disabled
                                : () {
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
  final bool isDisabled;
  final VoidCallback onTap;

  const LevelOption({
    Key? key,
    required this.level,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade300 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: isSelected && !isDisabled
                    ? Colors.black
                    : Colors.transparent,
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
                  color: isSelected && !isDisabled
                      ? Colors.black
                      : Colors.white,
                ),
                child: isSelected && !isDisabled
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : isDisabled
                    ? Icon(Icons.lock, size: 14, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 16),
              Text(
                level.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected && !isDisabled
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isDisabled ? Colors.grey.shade600 : Colors.black,
                ),
              ),
              if (isDisabled) ...[
                Spacer(),
                Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
