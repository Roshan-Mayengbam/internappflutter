import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/auth/skills.dart'; // Import Skills page instead of experience
import 'package:internappflutter/models/usermodel.dart';

class CourseRangePage extends StatefulWidget {
  final ExtendedUserModel? extendedUserModel;

  const CourseRangePage({super.key, required this.extendedUserModel});

  @override
  State<CourseRangePage> createState() => _CourseRangePageState();
}

class _CourseRangePageState extends State<CourseRangePage> {
  // Use a TextEditingController for the TextFormField
  final TextEditingController _yearController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedCourseRange;

  // Define the range for year selection: Current year + 5 years
  final int currentYear = DateTime.now().year;
  late final int minYear = currentYear;
  late final int maxYear = currentYear + 6;

  @override
  void initState() {
    super.initState();
    // Debug if (kDebugMode) print
    if (widget.extendedUserModel != null) {
      if (kDebugMode)
        print("=== RECEIVED DATA IN COURSE RANGE PAGE (MODIFIED UI) ===");
      if (kDebugMode) print("Name: ${widget.extendedUserModel!.name}");
      if (kDebugMode) print("===============================");
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  // Function to show the year picker dialog
  Future<void> _selectYear(BuildContext context) async {
    final int currentYear = DateTime.now().year;
    final int minYear = currentYear;
    final int maxYear = currentYear + 5;

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime? selectedDate = DateTime(
          currentYear,
        ); // Initialize with a default date

        return AlertDialog(
          title: const Text("Select Pass-out Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            // Use the YearPicker widget directly
            child: YearPicker(
              firstDate: DateTime(minYear),
              lastDate: DateTime(maxYear),
              selectedDate: selectedDate, // Must be non-null
              onChanged: (DateTime newDate) {
                // When a year is selected, update the selectedDate and close the dialog
                selectedDate = newDate;
                Navigator.pop(
                  context,
                  selectedDate,
                ); // Return the selected year
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close dialog without selecting anything
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedCourseRange = pickedDate.year.toString();
        _yearController.text = selectedCourseRange!;
        if (kDebugMode) print("Selected course year: $selectedCourseRange");
      });
    }
  }

  // Show validation message
  void showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Validation function for the TextFormField
  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your pass-out year';
    }
    final int? year = int.tryParse(value);
    if (year == null || year < minYear || year > maxYear) {
      return 'Year must be between $minYear and $maxYear';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double progress = selectedCourseRange != null ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Progress bar
            Row(
              children: [
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

            const SizedBox(height: 24),

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
                        const Text(
                          "OK, LET'S ADD YOUR PASSOUT YEAR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
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

            const SizedBox(height: 40),

            // 🚀 Replaced Fixed Options with Year Input Field
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _yearController,
                readOnly: true, // Forces usage of the picker
                decoration: InputDecoration(
                  labelText: 'Select Pass-out Year',
                  hintText: 'Tap to select year',
                  // Styling to match the original button aesthetic
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFB6A5FE),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFB6A5FE),
                      width: 3,
                    ),
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFB6A5FE),
                  ),
                  fillColor: const Color.fromRGBO(248, 248, 248, 1),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                onTap: () => _selectYear(context), // Open the year picker
                validator: _validateYear,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select a year between $minYear and $maxYear.',
              style: TextStyle(color: Colors.grey[600]),
            ),

            // Spacer to push the button to the bottom
            const Spacer(),
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
              // Validate form
              if (!_formKey.currentState!.validate()) {
                showValidationMessage(
                  'Please select a valid course pass-out year.',
                );
                return;
              }

              if (selectedCourseRange == null ||
                  widget.extendedUserModel == null) {
                showValidationMessage(
                  'An internal error occurred. Please select the year again.',
                );
                return;
              }

              // Create CourseRange model using your existing factory method
              final courseRangeModel = CourseRange.fromExtended(
                widget.extendedUserModel!,
                year: selectedCourseRange!,
              );

              if (kDebugMode)
                print("=== NAVIGATION DATA (USING YOUR MODEL) ===");
              if (kDebugMode)
                print("Full Model: ${courseRangeModel.toString()}");
              if (kDebugMode)
                print("===========================================");

              // Navigate to Skills page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Skills(extendedUserModel: courseRangeModel),
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
              selectedCourseRange != null ? 'Next' : 'Select Pass-out Year',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
