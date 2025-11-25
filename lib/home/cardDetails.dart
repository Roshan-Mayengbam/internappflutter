import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/chat/chatscreen.dart';
import 'package:url_launcher/url_launcher.dart';

class AppConstants {
  static const Color backgroundColor = Colors.white;
  static const Color borderColor = Colors.blue;
}

class Carddetails extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String about; // ✅ Declare as a field
  final String location;
  final String experienceLevel;
  final List<String> requirements;
  final String websiteUrl;
  final String? tagLabel;
  final String employmentType;
  final String rolesAndResponsibilities;
  final String duration;
  final String stipend;
  final String details;
  final String noOfOpenings;
  final List<String> perks; // ✅ Changed from String? to List<String>
  final String mode;
  final List skills;
  final String id;
  final String jobType;
  final Map<String, dynamic>? recruiter;
  final String salaryRange;

  const Carddetails({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.about, // ✅ Add to constructor parameters
    required this.location,
    required this.experienceLevel,
    required this.requirements,
    required this.websiteUrl,
    required this.tagLabel,
    required this.employmentType,
    required this.rolesAndResponsibilities,
    required this.duration,
    required this.stipend,
    required this.details,
    required this.noOfOpenings,
    required this.mode,
    required this.skills,
    required this.id,
    required this.jobType,
    this.recruiter,
    required this.salaryRange,
    required this.perks,
  });

  @override
  State<Carddetails> createState() => _CarddetailsState();
}

class _CarddetailsState extends State<Carddetails> {
  IconData icon = Icons.arrow_back;
  String _errorMessage = '';
  bool _isApplied = false; // Add this
  bool _isLoading = false; // Add this
  static const String baseUrl =
      'https://hyrup-730899264601.asia-south1.run.app';
  String get recruiterFirebaseId => widget.recruiter?['firebaseId'] ?? '';
  String get recruiterName => widget.recruiter?['name'] ?? 'Unknown Recruiter';

  String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> applyJob(String jobId, String jobType) async {
    print("🔄 Starting job application...");
    print("📋 Job ID: $jobId");
    print("🏢 Job Type: $jobType");

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "User not logged in";
        });
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          _errorMessage = "Could not get authentication token";
        });
        return;
      }

      final url = '$baseUrl/student/jobs/$jobId/$jobType/apply';
      print("🌐 API URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({}),
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Application submitted successfully");
        setState(() {
          _errorMessage = '';
          _isApplied = true;
        });
      } else {
        print("❌ Application failed with status: ${response.statusCode}");
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? "Failed to apply: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      setState(() {
        _errorMessage = "Error applying to job: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back when pressed
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(5, 0),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(5, 5),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
              ],
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 6, 7, 8),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: const Color.fromARGB(255, 7, 8, 9)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Color.fromARGB(255, 4, 4, 4),
                    thickness: 1,
                    height: 30,
                  ),
                  // Company Name with Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.companyName.isNotEmpty
                              ? widget.companyName
                              : 'Company',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Adds "..." if too long
                        ),
                      ),

                      const Spacer(),
                      _buildTag(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Job Title
                  Text(
                    widget.jobTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Location and Time
                  Text(
                    '${widget.location}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellow[700]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.yellow[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'On site',
                              style: TextStyle(
                                color: Colors.yellow[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellow[700]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.yellow[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Full Time',
                              style: TextStyle(
                                color: Colors.yellow[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      const Spacer(),
                      widget.tagLabel == 'In House'
                          ? Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  // Bottom shadow
                                  const BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(0, 5),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                  // Right shadow
                                  const BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(5, 0),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                  // Bottom-right corner shadow (to make it symmetric)
                                  const BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(5, 5),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                ],
                                color: AppConstants.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(
                                  top: BorderSide(
                                    color: Color.fromARGB(255, 6, 7, 8),
                                    width: 1,
                                  ), // thin
                                  left: BorderSide(
                                    color: Color.fromARGB(255, 6, 7, 8),
                                    width: 1,
                                  ), // thin
                                  right: BorderSide(
                                    color: Color.fromARGB(255, 6, 7, 8),
                                    width: 2,
                                  ), // thick
                                  bottom: BorderSide(
                                    color: Color.fromARGB(255, 6, 7, 8),
                                    width: 2,
                                  ), // thick
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () {
                                  // ✅ Pass the recruiter details to ChatScreen
                                  print('🔍 Current User ID: $currentUserId');
                                  print(
                                    'Recruiter Firebase ID: $recruiterFirebaseId',
                                  );
                                  print('🔍 Recruiter Name: $recruiterName');

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        currentUserId: currentUserId,
                                        otherUserId: recruiterFirebaseId,
                                        otherUserName: widget.companyName,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.comment,
                                  color: const Color.fromARGB(255, 7, 8, 9),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 0),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              top: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 1,
                              ),
                              right: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 2,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isApplied || _isLoading
                                ? null
                                : () async {
                                    print("Tag Label: ${widget.tagLabel}");
                                    print("Job Type: ${widget.jobType}");
                                    print("Website URL: ${widget.websiteUrl}");

                                    // Check if it's on-campus or external - open in browser
                                    if (widget.jobType == 'on-campus' ||
                                        widget.jobType == 'external') {
                                      if (widget.websiteUrl.isNotEmpty &&
                                          widget.websiteUrl !=
                                              'Apply via app' &&
                                          widget.websiteUrl != 'N/A') {
                                        try {
                                          String url = widget.websiteUrl;

                                          // Add https:// if not present
                                          if (!url.startsWith('http://') &&
                                              !url.startsWith('https://')) {
                                            url = 'https://$url';
                                          }

                                          print("Final URL: $url");

                                          final Uri uri = Uri.parse(url);

                                          // Try to launch the URL
                                          bool launched = await launchUrl(
                                            uri,
                                            mode: LaunchMode.inAppWebView,
                                          );

                                          if (!launched) {
                                            // If in-app doesn't work, try external browser
                                            launched = await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }

                                          if (!launched) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not open: $url',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print("Error launching URL: $e");
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Invalid URL: ${widget.websiteUrl}',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No application link available for this job',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                    // In House jobs - use API
                                    else if (widget.tagLabel?.trim() ==
                                        'In House') {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      await applyJob(widget.id, 'company');

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (_errorMessage.isEmpty && _isApplied) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: const BorderSide(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 30,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text('Success!'),
                                              ],
                                            ),
                                            content: const Text(
                                              'Your application has been submitted successfully!',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            actions: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.lightGreen[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (_errorMessage.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: const BorderSide(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text('Error'),
                                              ],
                                            ),
                                            content: Text(
                                              _errorMessage,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            actions: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isApplied
                                  ? Colors.grey[400]
                                  : Colors.lightGreen[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isApplied ? 'Applied' : 'Apply Now',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 6),
                              blurRadius: 0,
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(6, 0),
                              blurRadius: 0,
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(6, 6),
                              blurRadius: 0,
                              spreadRadius: -2,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            top: BorderSide(
                              color: Color.fromARGB(255, 6, 7, 8),
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Color.fromARGB(255, 6, 7, 8),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: Color.fromARGB(255, 6, 7, 8),
                              width: 2,
                            ),
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 6, 7, 8),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No. of',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.noOfOpenings,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Openings',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About the job Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About the job',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Job Details Grid
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Job Type',
                                widget.employmentType,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Duration',
                                widget.duration,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInfoCard('Mode', 'Online')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Stipend',
                                widget.salaryRange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Skills Section
                        // Replace the Skills Section in your Carddetails widget with this:

                        // Skills Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Skills:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              widget.skills.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: widget.skills
                                          .map(
                                            (skill) => _buildSkillChip(
                                              skill.toString(),
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : Text(
                                      'No skills specified',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Roles and Responsibility
                  const Text(
                    'Roles and Responsibility:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.rolesAndResponsibilities,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Perks
                  const Text(
                    'Perks:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),
                  for (var perk in widget.perks) ...[
                    _buildPerkButton(perk),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 20),

                  // Details
                  const Text(
                    'Details :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.details,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // About Company
                  const Text(
                    'About:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.about,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag() {
    String imagePath;
    if (widget.tagLabel == 'On Campus') {
      imagePath = 'assets/campus.png';
    } else if (widget.tagLabel == 'In House') {
      imagePath = 'assets/inhouse.png';
    } else {
      imagePath = 'assets/outreach.png';
    }

    return Image.asset(
      // ✅ No Positioned for Row
      imagePath,
      height: 50,
      width: 150,
      fit: BoxFit.contain,
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Colors.blue[400],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPerkButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue[400],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
