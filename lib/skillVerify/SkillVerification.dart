import 'package:flutter/material.dart';

import 'package:internappflutter/skillVerify/TestStart.dart';
import 'package:internappflutter/skillVerify/test1.dart';

class SkillVerification extends StatefulWidget {
  final Map<String, dynamic> userSkills;
  const SkillVerification({super.key, required this.userSkills});

  @override
  State<SkillVerification> createState() => _SkillVerificationState();
}

class _SkillVerificationState extends State<SkillVerification> {
  String? selectedSkill;
  String? selectedSkillLevel;

  @override
  Widget build(BuildContext context) {
    // Extract skills from the userSkills map with their levels
    Map<String, String> skillsWithLevels = {};

    if (widget.userSkills.containsKey('skills')) {
      // If skills is a map with skill names as keys
      if (widget.userSkills['skills'] is Map) {
        final skillsMap = widget.userSkills['skills'] as Map;
        skillsMap.forEach((key, value) {
          String level = 'unverified';
          if (value is Map && value.containsKey('level')) {
            level = value['level'].toString();
          }
          skillsWithLevels[key.toString()] = level;
        });
      }
    }
    // If skills are at the root level of userSkills map
    else {
      widget.userSkills.forEach((key, value) {
        String level = 'unverified';
        if (value is Map && value.containsKey('level')) {
          level = value['level'].toString();
        }
        skillsWithLevels[key.toString()] = level;
      });
    }

    List<String> skills = skillsWithLevels.keys.toList();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
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
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                SizedBox(width: 65),
                Text(
                  'Flex your skills',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              " 'Short & snappy quiz. Nail it and unlock shiny badges recruiters can't ignore.",
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pick your power skill 💡 ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '"Choose one of your skills to test first. You can always come back for more."',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 500,
              child: skills.isEmpty
                  ? Center(
                      child: Text(
                        'No skills available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 70,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: skills.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return SkillButton(
                          text: skills[index],
                          isSelected: selectedSkill == skills[index],
                          onTap: () {
                            setState(() {
                              selectedSkill = skills[index];
                              selectedSkillLevel =
                                  skillsWithLevels[skills[index]];
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestStart(
                                  selectedSkill: skills[index],
                                  UserSkillLevel:
                                      skillsWithLevels[skills[index]]!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            SizedBox(height: 24),
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
                onPressed: selectedSkill == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestStart(
                              selectedSkill: selectedSkill!,
                              UserSkillLevel: selectedSkillLevel!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6A5FE),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Makes the entire area tappable
      child: Container(
        height: 53,
        width: 133,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF40FFB9) : const Color(0xFFE3FEAA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF1FA7E3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
