import 'package:flutter/material.dart';
import 'package:internappflutter/auth/courserange.dart';
class Collegedetails extends StatefulWidget {
  const Collegedetails({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

   

  @override
  State<Collegedetails> createState() => _CollegedetailsState();
}

class _CollegedetailsState extends State<Collegedetails> {
  int filledFields = 0;
  final int totalFields = 4;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController1 = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void updateProgress() {
    int count = 0;
    if (nameController.text.isNotEmpty) count++;
    if (emailController.text.isNotEmpty) count++;
    if (phoneController.text.isNotEmpty) count++;
    if (phoneController1.text.isNotEmpty) count++;
    setState(() {
      filledFields = count;
    });
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(updateProgress);
    emailController.addListener(updateProgress);
    phoneController.addListener(updateProgress);
    phoneController1.addListener(updateProgress);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    phoneController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = filledFields / totalFields;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).maybePop();
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
            SizedBox(height: 24),
            // GIF widget inserted here
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 164,
                  height: 205,
                  child: Opacity(
                    opacity: 1, // Use your opacity value
                    child: Transform.rotate(
                      angle: 0, // Use your angle value in radians if needed
                      child: Image.asset(
                        'assets/aa.gif', // Replace with your actual GIF path
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                Stack(
                  children: [
                    SizedBox(
                      height: 62,
                      width: 215,
                      child: Image.asset('assets/Union.png'),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,

                      child: SizedBox(
                        width: 215,
                        child: Text(
                          'COOL! LET’S ADD YOUR COLLEGE DETAILS.',
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
            SizedBox(height: 24),
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: ' collage Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'university name ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'degree',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: phoneController1,
                decoration: InputDecoration(
                  labelText: 'collage email id',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CourseRangePage()),
                  );
                  // Add your action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
