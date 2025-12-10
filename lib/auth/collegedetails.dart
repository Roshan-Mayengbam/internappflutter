import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';
import 'package:internappflutter/auth/courserange.dart';
import 'package:internappflutter/models/usermodel.dart';

class Collegedetails extends StatefulWidget {
  final UserModel? userModel;

  const Collegedetails({super.key, this.userModel});

  @override
  State<Collegedetails> createState() => _CollegedetailsState();
}

class _CollegedetailsState extends State<Collegedetails> {
  int filledFields = 0;
  final int totalFields = 3;

  String? selectedCollege;
  String? selectedUniversity;
  String? selectedDegree;
  final _formKey = GlobalKey<FormState>();
  String? selectedEmailId;

  final TextEditingController _collegeSearchController =
      TextEditingController();
  final TextEditingController _degreeSearchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Timer? _debounce;
  List<Map<String, dynamic>> _collegeSearchResults = [];
  // Cache for the large universities dataset fetched from GitHub raw JSON.
  List<dynamic>? _universitiesCache;
  List<String> _allDegrees = [];
  List<String> _filteredDegrees = [];

  bool _isSearching = false;
  bool _showCollegeDropdown = false;
  bool _showDegreeDropdown = false;
  bool _isLoadingDegrees = true;

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
      if (kDebugMode) print("Received user data in CollegeDetails:");
      if (kDebugMode) print("Name: ${widget.userModel!.name}");
      if (kDebugMode) print("Email: ${widget.userModel!.email}");
      if (kDebugMode) print("Phone: ${widget.userModel!.phone}");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _collegeSearchController.dispose();
    _degreeSearchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadDegreesFromJson() async {
    try {
      String jsonString = await rootBundle.loadString('assets/degree.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      List<String> allDegrees = [];

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

      allDegrees.sort();

      setState(() {
        _allDegrees = allDegrees;
        _filteredDegrees = allDegrees;
        _isLoadingDegrees = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading degrees from JSON: $e');
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

// Replace your entire _searchColleges method with this:

Future<void> _searchColleges(String query) async {
  if (query.length < 1) {
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
    final collection = FirebaseFirestore.instance.collection("colleges");
    String lowerQuery = query.toLowerCase();

    if (kDebugMode) print('Searching for: $lowerQuery');

    // Try Method 1: Using orderBy with startAt/endAt
    QuerySnapshot querySnapshot;
    
    try {
      querySnapshot = await collection
          .orderBy('searchName')
          .startAt([lowerQuery])
          .endAt([lowerQuery + '\uf8ff'])
          .limit(50)
          .get();
      
      if (kDebugMode) print('Method 1 returned ${querySnapshot.docs.length} docs');
    } catch (e) {
      if (kDebugMode) print('Method 1 failed: $e, trying Method 2');
      
      // Method 2: Simple get all and filter client-side (works without index)
      querySnapshot = await collection.limit(100).get();
      if (kDebugMode) print('Method 2 returned ${querySnapshot.docs.length} docs');
    }

    List<Map<String, dynamic>> results = [];
    
    for (var doc in querySnapshot.docs) {
      try {
        String docName = doc['name'] ?? '';
        String searchName = doc.data().toString().contains('searchName') 
            ? (doc['searchName'] ?? '') 
            : docName.toLowerCase();
        
        if (kDebugMode) print('Doc: $docName, SearchName: $searchName');
        
        // Check if it matches the query
        if (searchName.startsWith(lowerQuery) || 
            docName.toLowerCase().startsWith(lowerQuery)) {
          results.add({
            'name': docName,
            'state': doc.data().toString().contains('state') ? (doc['state'] ?? '') : '',
            'city': doc.data().toString().contains('city') ? (doc['city'] ?? '') : '',
            'address': doc.data().toString().contains('address') ? (doc['address'] ?? '') : '',
          });
        }
      } catch (e) {
        if (kDebugMode) print('Error processing doc: $e');
      }
    }

    // Limit to top 10 results
    results = results.take(10).toList();

    if (kDebugMode) print('Final results: ${results.length}');

    setState(() {
      _collegeSearchResults = results;
      _isSearching = false;
    });

    // If no results from Firestore, use fallback
    if (results.isEmpty) {
      if (kDebugMode) print('No results, using fallback');
      _setFallbackColleges(query);
    }
  } catch (e) {
    if (kDebugMode) print('Error searching colleges: $e');
    setState(() {
      _isSearching = false;
    });
    _setFallbackColleges(query);
  }
}

  
  void _setFallbackColleges(String query) {
    final fallbackColleges = [
      {
        'name': 'Indian Institute of Technology Delhi',
        'state': 'Delhi',
        'city': 'New Delhi',
        'address': 'Hauz Khas',
      },
      {
        'name': 'Indian Institute of Technology Bombay',
        'state': 'Maharashtra',
        'city': 'Mumbai',
        'address': 'Powai',
      },
      {
        'name': 'Indian Institute of Science',
        'state': 'Karnataka',
        'city': 'Bangalore',
        'address': 'Malleshwaram',
      },
      {
        'name': 'Jawaharlal Nehru University',
        'state': 'Delhi',
        'city': 'New Delhi',
        'address': 'New Mehrauli Road',
      },
      {
        'name': 'University of Delhi',
        'state': 'Delhi',
        'city': 'New Delhi',
        'address': 'Delhi University North Campus',
      },
      {
        'name': 'Anna University',
        'state': 'Tamil Nadu',
        'city': 'Chennai',
        'address': 'Sardar Patel Road, Guindy',
      },
      {
        'name': 'VIT University',
        'state': 'Tamil Nadu',
        'city': 'Vellore',
        'address': 'Katpadi',
      },
      {
        'name': 'SRM Institute of Science and Technology',
        'state': 'Tamil Nadu',
        'city': 'Chennai',
        'address': 'Kattankulathur',
      },
      {
        'name': 'Manipal Academy of Higher Education',
        'state': 'Karnataka',
        'city': 'Manipal',
        'address': 'Madhav Nagar',
      },
      {
        'name': 'Birla Institute of Technology and Science',
        'state': 'Rajasthan',
        'city': 'Pilani',
        'address': 'Vidya Vihar',
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
    });
    updateProgress();
  }

  void updateProgress() {
    int count = 0;
    if (selectedCollege != null) count++;
    if (selectedUniversity != null) count++;
    if (selectedDegree != null) count++;

    setState(() {
      filledFields = count;
    });
  }

  bool get isFormComplete {
    return selectedCollege != null &&
        selectedUniversity != null &&
        selectedDegree != null;
  }

  void showValidationMessage() {
    List<String> missingFields = [];
    if (selectedCollege == null) missingFields.add('College Name');
    if (selectedUniversity == null) missingFields.add('University');
    if (selectedDegree == null) missingFields.add('Degree');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please provide: ${missingFields.join(', ')}',
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
                  child: Form(
                    key: _formKey,
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
                                  hintText: 'Search from 43,000+ colleges...',
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
                                textInputAction: TextInputAction.search,
                                onFieldSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _searchColleges(value);
                                  }
                                },
                                onChanged: _onCollegeSearchChanged,
                                onTap: () {
                                  setState(() {
                                    _showCollegeDropdown = true;
                                  });
                                  if (_collegeSearchController
                                      .text
                                      .isNotEmpty) {
                                    _searchColleges(
                                      _collegeSearchController.text,
                                    );
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
                                          '${college['city']}, ${college['state']}',
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
                          'College Email ID ',
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
                            border:
                                (selectedEmailId == null ||
                                    selectedEmailId!.isEmpty)
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
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: 'Enter your college email',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                selectedEmailId = value.isEmpty ? null : value;
                              });
                              updateProgress();
                            },
                          ),
                        ),

                        SizedBox(height: 24),
                      ],
                    ),
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
              if (!_formKey.currentState!.validate()) {
                return;
              }

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
                collegeEmailId: selectedEmailId ?? '',
              );

              if (kDebugMode) {
                print("Extended user model with college details:");
              }
              if (kDebugMode) print(extendedUserModel.toString());

              Navigator.push(
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
