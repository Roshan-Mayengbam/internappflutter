import 'package:flutter/material.dart';
import 'package:internappflutter/auth/courserange.dart';
import 'package:internappflutter/models/usermodel.dart';

class Collegedetails extends StatefulWidget {
  final UserModel? userModel; // ✅ Fixed parameter declaration

  const Collegedetails({super.key, this.userModel});

  @override
  State<Collegedetails> createState() => _CollegedetailsState();
}

class _CollegedetailsState extends State<Collegedetails> {
  int filledFields = 0;
  final int totalFields = 4;

  String? selectedCollege;
  String? selectedUniversity;
  String? selectedDegree;
  String? selectedEmailId;

  // Sample data for dropdowns
  final List<String> colleges = [
    'Sastra College',
    'Anna University',
    'VIT University',
    'SRM University',
    'Amrita University',
  ];

  final List<String> universities = [
    'Deemed University',
    'State University',
    'Central University',
    'Private University',
  ];

  final List<String> degrees = [
    'Bachelor of Engineering',
    'Bachelor of Technology',
    'Bachelor of Science',
    'Bachelor of Arts',
    'Master of Engineering',
    'Master of Technology',
  ];

  final List<String> emailIds = [
    'student@sastra.edu',
    'student@anna.edu.in',
    'student@vit.ac.in',
    'student@srmist.edu.in',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Debug print to see received user data
    if (widget.userModel != null) {
      print("Received user data in CollegeDetails:");
      print("Name: ${widget.userModel!.name}");
      print("Email: ${widget.userModel!.email}");
      print("Phone: ${widget.userModel!.phone}");
    }
  }

  void updateProgress() {
    int count = 0;
    if (selectedCollege != null) count++;
    if (selectedUniversity != null) count++;
    if (selectedDegree != null) count++;
    if (selectedEmailId != null) count++;
    setState(() {
      filledFields = count;
    });
  }

  // ✅ Check if all fields are filled
  bool get isFormComplete {
    return selectedCollege != null &&
        selectedUniversity != null &&
        selectedDegree != null &&
        selectedEmailId != null;
  }

  // ✅ Show validation message
  void showValidationMessage() {
    List<String> missingFields = [];
    if (selectedCollege == null) missingFields.add('College Name');
    if (selectedUniversity == null) missingFields.add('University');
    if (selectedDegree == null) missingFields.add('Degree');
    if (selectedEmailId == null) missingFields.add('College Email ID');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please select: ${missingFields.join(', ')}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = filledFields / totalFields;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            // Progress bar with back button
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: const Color.fromARGB(255, 97, 251, 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Character and speech bubble
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character image
                Container(
                  width: 120,
                  height: 150,
                  child: Image.asset('assets/bear.gif', fit: BoxFit.contain),
                ),
                SizedBox(width: 16),

                // Speech bubble
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
                          "COOL! LET'S ADD YOUR COLLEGE DETAILS.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
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

            SizedBox(height: 40),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // College Name
                    Text(
                      'College Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: selectedCollege == null
                            ? Border.all(color: Colors.grey[300]!)
                            : Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedCollege,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        hint: Text(
                          'Select College',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        items: colleges.map((String college) {
                          return DropdownMenuItem<String>(
                            value: college,
                            child: Text(college),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCollege = newValue;
                          });
                          updateProgress();
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // University
                    Text(
                      'University',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: selectedUniversity == null
                            ? Border.all(color: Colors.grey[300]!)
                            : Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedUniversity,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        hint: Text(
                          'Select University',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        items: universities.map((String university) {
                          return DropdownMenuItem<String>(
                            value: university,
                            child: Text(university),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUniversity = newValue;
                          });
                          updateProgress();
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Degree
                    Text(
                      'Degree',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: selectedDegree == null
                            ? Border.all(color: Colors.grey[300]!)
                            : Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedDegree,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        hint: Text(
                          'Select Degree',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        items: degrees.map((String degree) {
                          return DropdownMenuItem<String>(
                            value: degree,
                            child: Text(degree),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDegree = newValue;
                          });
                          updateProgress();
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // College Email ID
                    Text(
                      'College Email ID',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: selectedEmailId == null
                            ? Border.all(color: Colors.grey[300]!)
                            : Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedEmailId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        hint: Text(
                          'Select Email Domain',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        items: emailIds.map((String emailId) {
                          return DropdownMenuItem<String>(
                            value: emailId,
                            child: Text(emailId),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedEmailId = newValue;
                          });
                          updateProgress();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next button with validation
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ Validate form completion
                  if (!isFormComplete) {
                    showValidationMessage();
                    return;
                  }

                  // ✅ Create extended user model with college details
                  final extendedUserModel = ExtendedUserModel(
                    // Base user data from previous page
                    name: widget.userModel?.name ?? 'Unknown User',
                    email: widget.userModel?.email ?? 'No Email',
                    phone: widget.userModel?.phone ?? '',
                    profileImageUrl: widget.userModel?.profileImageUrl,
                    uid: widget.userModel?.uid ?? '',
                    role: widget.userModel?.role ?? 'Student',
                    // College details
                    collegeName: selectedCollege!,
                    university: selectedUniversity!,
                    degree: selectedDegree!,
                    collegeEmailId: selectedEmailId!,
                  );

                  print("Extended user model with college details:");
                  print(extendedUserModel.toString());

                  // ✅ Navigate to next page with complete data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseRangePage(userModel: extendedUserModel),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormComplete
                      ? Colors.black
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isFormComplete ? 'Next' : 'Complete All Fields',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ✅ Extended UserModel class to include college details
class ExtendedUserModel extends UserModel {
  final String collegeName;
  final String university;
  final String degree;
  final String collegeEmailId;

  ExtendedUserModel({
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    required String uid,
    required String role,
    required this.collegeName,
    required this.university,
    required this.degree,
    required this.collegeEmailId,
  }) : super(
         name: name,
         email: email,
         phone: phone,
         profileImageUrl: profileImageUrl,
         uid: uid,
         role: role,
       );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'collegeName': collegeName,
      'university': university,
      'degree': degree,
      'collegeEmailId': collegeEmailId,
    });
    return baseMap;
  }

  @override
  String toString() {
    return 'ExtendedUserModel(${super.toString()}, collegeName: $collegeName, university: $university, degree: $degree, collegeEmailId: $collegeEmailId)';
  }
}
modified code 
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    nameController.addListener(
      updateProgress,
    ); //addListener → means: “Hey, whenever something inside this object changes, call this function.”
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
      backgroundColor: Color.fromARGB(255, 252, 252, 244),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
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
                          'Awesome! Tell Us About Your College.',
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
            Stack(
              children: [
                Container(height: 475, width: 400),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(child: Image.asset('assets/puzzle.png')),
                ),
                Column(
                  children: [
                    Container(
                      width: 390,
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black, // shadow color
                            offset: Offset(4, 4), // x = right, y = down
                            blurRadius: 0, // softens the shadow
                            spreadRadius: 1, // optional, how much it spreads
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // same as button radius
                      ),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'collage',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 390,
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black, // shadow color
                            offset: Offset(2, 2), // x = right, y = down
                            blurRadius: 0, // softens the shadow
                            spreadRadius: 1, // optional, how much it spreads
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // same as button radius
                      ),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'university Name',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 390,
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black, // shadow color
                            offset: Offset(4, 4), // x = right, y = down
                            blurRadius: 0, // softens the shadow
                            spreadRadius: 1, // optional, how much it spreads
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // same as button radius
                      ),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'degree',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 390,
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black, // shadow color
                            offset: Offset(4, 4), // x = right, y = down
                            blurRadius: 0, // softens the shadow
                            spreadRadius: 1, // optional, how much it spreads
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // same as button radius
                      ),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: phoneController1,
                          decoration: InputDecoration(
                            labelText: 'collage email id ',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            Spacer(),
            Container(
              width: 390,
              height: 54,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black, // shadow color
                    offset: Offset(4, 4), // x = right, y = down
                    blurRadius: 0, // softens the shadow
                    spreadRadius: 1, // optional, how much it spreads
                  ),
                ],
                borderRadius: BorderRadius.circular(8), // same as button radius
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Skills()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB6A5FE),
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
