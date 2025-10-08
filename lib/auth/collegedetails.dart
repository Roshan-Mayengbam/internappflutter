import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:internappflutter/auth/courserange.dart';
import 'package:internappflutter/auth/skills.dart';
import 'package:internappflutter/models/usermodel.dart';

class Collegedetails extends StatefulWidget {
  final UserModel? userModel;

  const Collegedetails({super.key, this.userModel});

  @override
  State<Collegedetails> createState() => _CollegedetailsState();
}

class _CollegedetailsState extends State<Collegedetails> {
  int filledFields = 0;
  final int totalFields = 3; // Reduced from 4 since email is optional

  String? selectedCollege;
  String? selectedUniversity;
  String? selectedDegree;
  String? selectedEmailId;

  // Controllers for search functionality
  final TextEditingController _collegeSearchController =
      TextEditingController();
  final TextEditingController _degreeSearchController = TextEditingController();

  Timer? _debounce;
  List<Map<String, dynamic>> _collegeSearchResults = [];
  List<String> _allDegrees = [];
  List<String> _filteredDegrees = [];

  bool _isSearching = false;
  bool _showCollegeDropdown = false;
  bool _showDegreeDropdown = false;
  bool _isLoadingDegrees = true;

  // Static data for university dropdown
  final List<String> universities = [
    'Deemed University',
    'State University',
    'Central University',
    'Private University',
    'Autonomous College',
    'Affiliated College',
  ];

  @override
  void initState() {
    super.initState();
    _loadDegreesFromJson();
    if (widget.userModel != null) {
      print("Received user data in CollegeDetails:");
      print("Name: ${widget.userModel!.name}");
      print("Email: ${widget.userModel!.email}");
      print("Phone: ${widget.userModel!.phone}");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _collegeSearchController.dispose();
    _degreeSearchController.dispose();
    super.dispose();
  }

  // Load degrees from JSON file
  Future<void> _loadDegreesFromJson() async {
    try {
      // Load the JSON file from assets
      String jsonString = await rootBundle.loadString('assets/degree.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      List<String> allDegrees = [];

      // Combine all degree types
      if (jsonData['undergraduate_degrees'] != null) {
        allDegrees.addAll(List<String>.from(jsonData['undergraduate_degrees']));
      }
      if (jsonData['postgraduate_degrees'] != null) {
        allDegrees.addAll(List<String>.from(jsonData['postgraduate_degrees']));
      }
      if (jsonData['doctoral_degrees'] != null) {
        allDegrees.addAll(List<String>.from(jsonData['doctoral_degrees']));
      }
      if (jsonData['diploma_degrees'] != null) {
        allDegrees.addAll(List<String>.from(jsonData['diploma_degrees']));
      }

      // Sort alphabetically
      allDegrees.sort();

      setState(() {
        _allDegrees = allDegrees;
        _filteredDegrees = allDegrees;
        _isLoadingDegrees = false;
      });
    } catch (e) {
      print('Error loading degrees from JSON: $e');
      // Fallback to hardcoded degrees
      setState(() {
        _allDegrees = [
          'Bachelor of Engineering (B.E)',
          'Bachelor of Technology (B.Tech)',
          'Bachelor of Science (B.Sc)',
          'Bachelor of Arts (B.A)',
          'Bachelor of Commerce (B.Com)',
          'Bachelor of Business Administration (BBA)',
          'Master of Engineering (M.E)',
          'Master of Technology (M.Tech)',
          'Master of Science (M.Sc)',
          'Master of Arts (M.A)',
          'Master of Business Administration (MBA)',
        ];
        _filteredDegrees = _allDegrees;
        _isLoadingDegrees = false;
      });
    }
  }

  // Filter degrees based on search query
  void _filterDegrees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDegrees = _allDegrees;
      } else {
        _filteredDegrees = _allDegrees
            .where(
              (degree) => degree.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      _showDegreeDropdown = _filteredDegrees.isNotEmpty;
    });
  }

  void _onDegreeSearchChanged(String value) {
    _filterDegrees(value);
  }

  void _selectDegree(String degree) {
    setState(() {
      selectedDegree = degree;
      _degreeSearchController.text = degree;
      _showDegreeDropdown = false;
    });
    updateProgress();
  }

  // API call to search colleges using Universities API
  Future<void> _searchColleges(String query) async {
    if (query.length < 2) {
      setState(() {
        _collegeSearchResults = [];
        _showCollegeDropdown = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showCollegeDropdown = true;
    });

    try {
      // Using Universities API - free API for educational institutions
      final response = await http
          .get(
            Uri.parse(
              'http://universities.hipolabs.com/search?name=$query&country=India',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _collegeSearchResults = data
              .take(20)
              .map(
                (item) => {
                  'name': item['name'] ?? 'Unknown',
                  'state': item['state-province'] ?? 'Unknown State',
                  'domain': item['domains']?.isNotEmpty == true
                      ? item['domains'][0]
                      : null,
                },
              )
              .toList();
        });
      } else {
        // Fallback to some popular Indian colleges if API fails
        _setFallbackColleges(query);
      }
    } catch (e) {
      print('Error searching colleges: $e');
      _setFallbackColleges(query);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _setFallbackColleges(String query) {
    final fallbackColleges = [
      {
        'name': 'Indian Institute of Technology Delhi',
        'state': 'Delhi',
        'domain': 'iitd.ac.in',
      },
      {
        'name': 'Indian Institute of Technology Bombay',
        'state': 'Maharashtra',
        'domain': 'iitb.ac.in',
      },
      {
        'name': 'Indian Institute of Science',
        'state': 'Karnataka',
        'domain': 'iisc.ac.in',
      },
      {
        'name': 'Jawaharlal Nehru University',
        'state': 'Delhi',
        'domain': 'jnu.ac.in',
      },
      {'name': 'University of Delhi', 'state': 'Delhi', 'domain': 'du.ac.in'},
      {
        'name': 'Anna University',
        'state': 'Tamil Nadu',
        'domain': 'annauniv.edu',
      },
      {'name': 'VIT University', 'state': 'Tamil Nadu', 'domain': 'vit.ac.in'},
      {
        'name': 'SRM Institute of Science and Technology',
        'state': 'Tamil Nadu',
        'domain': 'srmist.edu.in',
      },
      {
        'name': 'Manipal Academy of Higher Education',
        'state': 'Karnataka',
        'domain': 'manipal.edu',
      },
      {
        'name': 'Birla Institute of Technology and Science',
        'state': 'Rajasthan',
        'domain': 'bits-pilani.ac.in',
      },
    ];

    setState(() {
      _collegeSearchResults = fallbackColleges
          .where(
            (college) =>
                college['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _onCollegeSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchColleges(value);
    });
  }

  void _selectCollege(Map<String, dynamic> college) {
    setState(() {
      selectedCollege = college['name'];
      _collegeSearchController.text = college['name'];
      _showCollegeDropdown = false;

      // Auto-suggest email domain if available
      if (college['domain'] != null && selectedEmailId == null) {
        selectedEmailId = 'student@${college['domain']}';
      }
    });
    updateProgress();
  }

  void updateProgress() {
    int count = 0;
    if (selectedCollege != null) count++;
    if (selectedUniversity != null) count++;
    if (selectedDegree != null) count++;
    // Email is optional, so not counted in required fields
    setState(() {
      filledFields = count;
    });
  }

  bool get isFormComplete {
    return selectedCollege != null &&
        selectedUniversity != null &&
        selectedDegree != null;
    // Email is optional
  }

  void showValidationMessage() {
    List<String> missingFields = [];
    if (selectedCollege == null) missingFields.add('College Name');
    if (selectedUniversity == null) missingFields.add('University');
    if (selectedDegree == null) missingFields.add('Degree');

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
      body: GestureDetector(
        onTap: () {
          // Hide dropdowns when tapping outside
          setState(() {
            _showCollegeDropdown = false;
            _showDegreeDropdown = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: Padding(
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
                  Container(
                    width: 120,
                    height: 150,
                    child: Image.asset('assets/bear.gif', fit: BoxFit.contain),
                  ),
                  SizedBox(width: 16),
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
                      // College Name Search
                      Text(
                        'College Name *',
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
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _collegeSearchController,
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
                                hintText: 'Search for your college...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                suffixIcon: _isSearching
                                    ? Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.grey,
                                                ),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.search,
                                        color: Colors.grey[400],
                                      ),
                              ),
                              onChanged: _onCollegeSearchChanged,
                              onTap: () {
                                if (_collegeSearchResults.isNotEmpty) {
                                  setState(() {
                                    _showCollegeDropdown = true;
                                  });
                                }
                              },
                            ),
                            if (_showCollegeDropdown &&
                                _collegeSearchResults.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _collegeSearchResults.length,
                                  itemBuilder: (context, index) {
                                    final college =
                                        _collegeSearchResults[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        college['name'],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        college['state'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      onTap: () => _selectCollege(college),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // University
                      Text(
                        'University Type *',
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
                            'Select University Type',
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

                      // Degree (Searchable)
                      Text(
                        'Degree *',
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
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _degreeSearchController,
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
                                hintText: _isLoadingDegrees
                                    ? 'Loading degrees...'
                                    : 'Search for your degree...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                suffixIcon: _isLoadingDegrees
                                    ? Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.grey,
                                                ),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.search,
                                        color: Colors.grey[400],
                                      ),
                              ),
                              enabled: !_isLoadingDegrees,
                              onChanged: _onDegreeSearchChanged,
                              onTap: () {
                                if (!_isLoadingDegrees &&
                                    _filteredDegrees.isNotEmpty) {
                                  setState(() {
                                    _showDegreeDropdown = true;
                                  });
                                }
                              },
                            ),
                            if (_showDegreeDropdown &&
                                _filteredDegrees.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredDegrees.length,
                                  itemBuilder: (context, index) {
                                    final degree = _filteredDegrees[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        degree,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      onTap: () => _selectDegree(degree),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // College Email ID (Optional)
                      Text(
                        'College Email ID (Optional)',
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
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
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
                            hintText: 'Enter your college email (optional)',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              selectedEmailId = value.isEmpty ? null : value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              if (!isFormComplete) {
                showValidationMessage();
                return;
              }

              final extendedUserModel = ExtendedUserModel.fromUserModel(
                widget.userModel ??
                    UserModel(
                      name: 'Unknown User',
                      email: 'No Email',
                      uid: '',
                      role: 'Student',
                    ),
                collegeName: selectedCollege!,
                university: selectedUniversity!,
                degree: selectedDegree!,
                collegeEmailId: selectedEmailId as String, // Can be null
              );

              print("Extended user model with college details:");
              print(extendedUserModel.toString());

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CourseRangePage(extendedUserModel: extendedUserModel),
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
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
// ✅ Extended UserModel class to include college details

// modified code
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int filledFields = 0;
//   final int totalFields = 4;
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController1 = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   void updateProgress() {
//     int count = 0;
//     if (nameController.text.isNotEmpty) count++;
//     if (emailController.text.isNotEmpty) count++;
//     if (phoneController.text.isNotEmpty) count++;
//     if (phoneController1.text.isNotEmpty) count++;
//     setState(() {
//       filledFields = count;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     nameController.addListener(
//       updateProgress,
//     ); //addListener → means: “Hey, whenever something inside this object changes, call this function.”
//     emailController.addListener(updateProgress);
//     phoneController.addListener(updateProgress);
//     phoneController1.addListener(updateProgress);
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     phoneController1.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double progress = filledFields / totalFields;
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 252, 252, 244),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(builder: (context) => RegisterPage()),
//                     // );
//                   },
//                 ),
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: LinearProgressIndicator(
//                       value: progress,
//                       minHeight: 10,
//                       backgroundColor: Colors.grey[300],
//                       color: Colors.greenAccent,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             // GIF widget inserted here
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 164,
//                   height: 205,
//                   child: Opacity(
//                     opacity: 1, // Use your opacity value
//                     child: Transform.rotate(
//                       angle: 0, // Use your angle value in radians if needed
//                       child: Image.asset(
//                         'assets/aa.gif', // Replace with your actual GIF path
//                         fit: BoxFit.fill,
//                       ),
//                     ),
//                   ),
//                 ),

//                 Stack(
//                   children: [
//                     SizedBox(
//                       height: 62,
//                       width: 215,
//                       child: Image.asset('assets/Union.png'),
//                     ),
//                     Positioned(
//                       top: 16,
//                       left: 16,

//                       child: SizedBox(
//                         width: 215,
//                         child: Text(
//                           'Awesome! Tell Us About Your College.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             Stack(
//               children: [
//                 Container(height: 475, width: 400),
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: Container(child: Image.asset('assets/puzzle.png')),
//                 ),
//                 Column(
//                   children: [
//                     Container(
//                       width: 390,
//                       height: 54,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black, // shadow color
//                             offset: Offset(4, 4), // x = right, y = down
//                             blurRadius: 0, // softens the shadow
//                             spreadRadius: 1, // optional, how much it spreads
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(
//                           8,
//                         ), // same as button radius
//                       ),
//                       child: Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12),
//                         child: TextField(
//                           controller: nameController,
//                           decoration: InputDecoration(
//                             labelText: 'collage',
//                             labelStyle: const TextStyle(
//                               color: Colors.black54,
//                               fontSize: 16,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 14,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 50),
//                     Container(
//                       width: 390,
//                       height: 54,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black, // shadow color
//                             offset: Offset(2, 2), // x = right, y = down
//                             blurRadius: 0, // softens the shadow
//                             spreadRadius: 1, // optional, how much it spreads
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(
//                           8,
//                         ), // same as button radius
//                       ),
//                       child: Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12),
//                         child: TextField(
//                           controller: emailController,
//                           decoration: InputDecoration(
//                             labelText: 'university Name',
//                             labelStyle: const TextStyle(
//                               color: Colors.black54,
//                               fontSize: 16,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 14,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 50),
//                     Container(
//                       width: 390,
//                       height: 54,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black, // shadow color
//                             offset: Offset(4, 4), // x = right, y = down
//                             blurRadius: 0, // softens the shadow
//                             spreadRadius: 1, // optional, how much it spreads
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(
//                           8,
//                         ), // same as button radius
//                       ),
//                       child: Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12),
//                         child: TextField(
//                           controller: phoneController,
//                           decoration: InputDecoration(
//                             labelText: 'degree',
//                             labelStyle: const TextStyle(
//                               color: Colors.black54,
//                               fontSize: 16,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 14,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 50),
//                     Container(
//                       width: 390,
//                       height: 54,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black, // shadow color
//                             offset: Offset(4, 4), // x = right, y = down
//                             blurRadius: 0, // softens the shadow
//                             spreadRadius: 1, // optional, how much it spreads
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(
//                           8,
//                         ), // same as button radius
//                       ),
//                       child: Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12),
//                         child: TextField(
//                           controller: phoneController1,
//                           decoration: InputDecoration(
//                             labelText: 'collage email id ',
//                             labelStyle: const TextStyle(
//                               color: Colors.black54,
//                               fontSize: 16,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 14,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.black,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 50),
//             Spacer(),
//             Container(
//               width: 390,
//               height: 54,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black, width: 1),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black, // shadow color
//                     offset: Offset(4, 4), // x = right, y = down
//                     blurRadius: 0, // softens the shadow
//                     spreadRadius: 1, // optional, how much it spreads
//                   ),
//                 ],
//                 borderRadius: BorderRadius.circular(8), // same as button radius
//               ),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => Skills()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFFB6A5FE),
//                   foregroundColor: Colors.white,
//                   elevation: 4,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   textStyle: TextStyle(fontSize: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text('next'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
