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

  @override
  Widget build(BuildContext context) {
    // Extract skills from the userSkills map
    List<String> skills = [];
    if (widget.userSkills.containsKey('skills')) {
      // If skills is a list
      if (widget.userSkills['skills'] is List) {
        skills = List<String>.from(widget.userSkills['skills']);
      }
      // If skills is a map with skill names as keys
      else if (widget.userSkills['skills'] is Map) {
        skills = (widget.userSkills['skills'] as Map).keys
            .map((e) => e.toString())
            .toList();
      }
    }
    // If skills are at the root level of userSkills map
    else {
      skills = widget.userSkills.keys.map((e) => e.toString()).toList();
    }

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
            Container(
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
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: skills.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return SkillButton(
                          text: skills[index],
                          isSelected: selectedSkill == skills[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TestStart(selectedSkill: skills[index]),
                              ),
                            );
                            setState(() {
                              selectedSkill = skills[index];
                            });
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
                            builder: (context) =>
                                TestStart(selectedSkill: selectedSkill!),
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
    return Container(
      height: 53,
      width: 133,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(4, 4),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF40FFB9) : Color(0xFFE3FEAA),
          elevation: 0,
          minimumSize: Size(120, 53),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 20, color: Color(0xFF1FA7E3)),
        ),
      ),
    );
  }
}
