import 'package:flutter/material.dart';
import 'package:internappflutter/auth/collegedetails.dart';

class CourseRangePage extends StatefulWidget {
  const CourseRangePage({super.key});

  @override
  State<CourseRangePage> createState() => _CourseRangePageState();
}

class _CourseRangePageState extends State<CourseRangePage> {
  int? selectedOption;

  final List<String> options = ['2010-2013', '2013-2017', '2017-2020', '2020+'];

  @override
  Widget build(BuildContext context) {
    double progress = selectedOption != null ? 1.0 : 0.0;

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
                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => Collegedetails()),
                    );
                  },
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      SizedBox(), // Keeps the row height
                      SizedBox(
                        width: 300,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                          minHeight: 8,
                        ),
                      ),
                    ],
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
                  width: 164,
                  height: 205,
                  child: Image.asset('assets/aa.gif', fit: BoxFit.fill),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 62,
                          width: 205,
                          child: Image.asset('assets/Union.png'),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: SizedBox(
                            width: 215,
                            child: Text(
                              'OK, LET’S ADD YOUR COURSE RANGE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily:
                                    'Jost', // Ensure Jost is added in pubspec.yaml
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            // Options
            ...List.generate(options.length, (index) {
              final bool isSelected = selectedOption == index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Material(
                  elevation: 0, // Remove Material elevation
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        selectedOption = index;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromRGBO(
                                232,
                                226,
                                254,
                                1,
                              ) // Light color of B6A5FE
                            : const Color.fromRGBO(
                                248,
                                248,
                                248,
                                1,
                              ), // Inside color when not selected
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
                                  color: const Color.fromRGBO(182, 165, 254, 1),
                                  width: 5,
                                )
                              : BorderSide.none,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color.fromRGBO(182, 165, 254, 1)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption != null
                    ? () {
                        // Next action
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
