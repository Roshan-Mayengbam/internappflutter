import 'package:flutter/material.dart';
import 'package:internappflutter/aboutYou/uploadProfilePic.dart';
import 'package:internappflutter/auth/collegedetails.dart';
import 'package:internappflutter/auth/skills.dart'; // Import Skills page instead of experience
import 'package:internappflutter/models/usermodel.dart';

class CourseRangePage extends StatefulWidget {
  final ExtendedUserModel? extendedUserModel;

  const CourseRangePage({super.key, required this.extendedUserModel});

  @override
  State<CourseRangePage> createState() => _CourseRangePageState();
}

class _CourseRangePageState extends State<CourseRangePage> {
  int? selectedOption;
  String? selectedCourseRange;

  final List<String> options = ['2010-2013', '2013-2017', '2017-2020', '2020+'];

  @override
  void initState() {
    super.initState();
    // ✅ Debug print to see received user data - FIXED parameter name
    if (widget.extendedUserModel != null) {
      print("=== RECEIVED DATA IN COURSE RANGE PAGE ===");
      print("Name: ${widget.extendedUserModel!.name}");
      print("Email: ${widget.extendedUserModel!.email}");
      print("Phone: ${widget.extendedUserModel!.phone}");
      print("UID: ${widget.extendedUserModel!.uid}");
      print("Role: ${widget.extendedUserModel!.role}");
      print("College Name: ${widget.extendedUserModel!.collegeName}");
      print("University: ${widget.extendedUserModel!.university}");
      print("Degree: ${widget.extendedUserModel!.degree}");
      print("College Email: ${widget.extendedUserModel!.collegeEmailId}");
      print("Skills: ${widget.extendedUserModel!.skills}");
      print("Jobs: ${widget.extendedUserModel!.jobs}");
      print("===============================");
    }
  }

  // ✅ Show validation message
  void showValidationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please select your course range to continue',
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
    double progress = selectedOption != null ? 1.0 : 0.0;

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

            SizedBox(height: 24),

            // GIF and message box image
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 150,
                  child: Image.asset('assets/bear.gif', fit: BoxFit.fill),
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
                          "OK, LET'S ADD YOUR COURSE RANGE",
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

            SizedBox(height: 40),

            // Options - Expanded to take available space
            Expanded(
              child: Column(
                children: [
                  ...List.generate(options.length, (index) {
                    final bool isSelected = selectedOption == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        elevation: 0,
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedOption = index;
                              selectedCourseRange = options[index];
                            });
                            print("Selected course range: ${options[index]}");
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(232, 226, 254, 1)
                                  : const Color.fromRGBO(248, 248, 248, 1),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    181,
                                    169,
                                    235,
                                  ).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border(
                                bottom: isSelected
                                    ? BorderSide(
                                        color: const Color.fromRGBO(
                                          182,
                                          165,
                                          254,
                                          1,
                                        ),
                                        width: 5,
                                      )
                                    : BorderSide.none,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color.fromRGBO(182, 165, 254, 1)
                                        : Colors.black,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color.fromRGBO(
                                      182,
                                      165,
                                      254,
                                      1,
                                    ),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
            onPressed: () {
              // ✅ Validate selection
              if (selectedOption == null) {
                showValidationMessage();
                return;
              }

              // ✅ Create CourseRange model from ExtendedUserModel + selected year
              final courseRangeModel = CourseRange.fromExtended(
                widget.extendedUserModel!,
                year: selectedCourseRange!,
              );

              // ✅ Print all data INCLUDING course range
              print(
                "=== COMPLETE DATA BEFORE NAVIGATION (WITH COURSE RANGE) ===",
              );
              print("Name: ${courseRangeModel.name}");
              print("Email: ${courseRangeModel.email}");
              print("Phone: ${courseRangeModel.phone}");
              print("UID: ${courseRangeModel.uid}");
              print("Role: ${courseRangeModel.role}");
              print("College Name: ${courseRangeModel.collegeName}");
              print("University: ${courseRangeModel.university}");
              print("Degree: ${courseRangeModel.degree}");
              print("College Email: ${courseRangeModel.collegeEmailId}");
              print("Skills: ${courseRangeModel.skills}");
              print("Jobs: ${courseRangeModel.jobs}");
              print(
                "Course Range/Year: ${courseRangeModel.year}",
              ); // NEW FIELD ADDED
              print("Full Model: ${courseRangeModel.toString()}");
              print("===========================================");

              // ✅ Navigate to Skills page (which then goes to Experience)
              // Note: You might want to navigate to Skills page instead of ExperiencePage directly
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Skills(
                    extendedUserModel:
                        courseRangeModel, // Pass the CourseRange model
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB6A5FE),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedOption != null ? 'Next' : 'Select Course Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class FinalUserModel extends ExtendedUserModel {
  final String courseRange;

  FinalUserModel({
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    required String uid,
    required String role,
    required String collegeName,
    required String university,
    required String degree,
    required String collegeEmailId,
    required this.courseRange,
  }) : super(
         name: name,
         email: email,
         phone: phone,

         uid: uid,
         role: role,
         collegeName: collegeName,
         university: university,
         degree: degree,
         collegeEmailId: collegeEmailId,
       );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({'courseRange': courseRange});
    return baseMap;
  }

  @override
  String toString() {
    return 'FinalUserModel(${super.toString()}, courseRange: $courseRange)';
  }
}

/// modified code
// class CourseRangePage extends StatefulWidget {
//   const CourseRangePage({super.key});

//   @override
//   State<CourseRangePage> createState() => _CourseRangePageState();
// }

// class _CourseRangePageState extends State<CourseRangePage> {
//   int? selectedOption;

//   final List<String> options = ['2010-2013', '2013-2017', '2017-2020', '2020+'];

//   @override
//   Widget build(BuildContext context) {
//     double progress = selectedOption != null ? 1.0 : 0.0;

//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 252, 252, 244),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     // Navigator.pop(
//                     //   context,
//                     //   MaterialPageRoute(builder: (context) => Collegedetails()),
//                     // );
//                   },
//                 ),
//                 Expanded(
//                   child: Stack(
//                     alignment: Alignment.topLeft,
//                     children: [
//                       SizedBox(), // Keeps the row height
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8.0),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             minHeight: 10,
//                             backgroundColor: Colors.grey[300],
//                             color: Colors.greenAccent,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             // GIF and message box image
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 164,
//                   height: 205,
//                   child: Image.asset('assets/aa.gif', fit: BoxFit.fill),
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Stack(
//                       children: [
//                         SizedBox(
//                           height: 62,
//                           width: 205,
//                           child: Image.asset('assets/Union.png'),
//                         ),
//                         Positioned(
//                           top: 16,
//                           left: 16,
//                           child: SizedBox(
//                             width: 215,
//                             child: Text(
//                               'YOO ! WHICH YEAR ARE U PASSING OUT',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 fontFamily:
//                                     'Jost', // Ensure Jost is added in pubspec.yaml
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             // Options
//             Stack(
//               children: [
//                 Container(height: 470, width: 400),
//                 Positioned(
//                   right: 0,
//                   top:
//                       8.0 * 4 * 2 +
//                       70, //  adjust this based on padding & item height
//                   child: Container(
//                     height: 294,
//                     width: 261,
//                     child: Image.asset('assets/puzzle.png', fit: BoxFit.cover),
//                   ),
//                 ),
//                 // All options
//                 Column(
//                   children: List.generate(options.length, (index) {
//                     final bool isSelected = selectedOption == index;
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Material(
//                         elevation: 0,
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(12),
//                           onTap: () {
//                             setState(() {
//                               selectedOption = index;
//                             });
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? const Color.fromRGBO(232, 226, 254, 1)
//                                   : const Color.fromRGBO(248, 248, 248, 1),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color.fromARGB(
//                                     255,
//                                     181,
//                                     169,
//                                     235,
//                                   ).withOpacity(0.5),
//                                   blurRadius: 10,
//                                   offset: Offset(0, 4),
//                                 ),
//                               ],
//                               border: Border(
//                                 bottom: isSelected
//                                     ? const BorderSide(
//                                         color: Color.fromRGBO(182, 165, 254, 1),
//                                         width: 5,
//                                       )
//                                     : BorderSide.none,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 16,
//                               horizontal: 16,
//                             ),
//                             child: Text(
//                               options[index],
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected
//                                     ? const Color.fromRGBO(182, 165, 254, 1)
//                                     : Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//             Spacer(),
//             if (selectedOption != null)
//               Container(
//                 width: 390,
//                 height: 54,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black, width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black, // shadow color
//                       offset: Offset(4, 4), // x = right, y = down
//                       blurRadius: 0, // softens the shadow
//                       spreadRadius: 1, // optional, how much it spreads
//                     ),
//                   ],
//                   borderRadius: BorderRadius.circular(
//                     8,
//                   ), // same as button radius
//                 ),
//                 child: ElevatedButton(
//                   onPressed: selectedOption != null
//                       ? () {
//                           // MaterialPageRoute(
//                           //   builder: (context) => ExplorePage(),
//                           // );
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFB6A5FE),
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text('Next'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
