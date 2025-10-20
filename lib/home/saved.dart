import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/custom_app_bar.dart';
import 'package:internappflutter/core/components/custom_button.dart';
import 'package:internappflutter/core/components/jobs_page/custom_carousel_section.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:internappflutter/package/ViewMores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";
  final String baseUrl2 = "http://10.196.234.157:3000";
  List<Job> savedJobs = []; // ✅ Changed to List<Job>
  List<Job> appliedJobs = []; // ✅ Changed to List<Job>
  List<dynamic> appliedApplications = []; // Store full application data
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([fetchSavedJobs(), fetchAppliedJobs()]);
  }

  Future<void> fetchSavedJobs() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
        });
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          errorMessage = "Could not get authentication token";
        });
        return;
      }

      print("🔄 Fetching saved jobs...");

      final response = await http.get(
        Uri.parse('$baseUrl/student/saves'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          print("✅ Saved jobs: $data");
          // ✅ Convert JSON to Job objects
          List<dynamic> savesData = data['saves'] ?? [];
          savedJobs = savesData
              .map((jobJson) => Job.fromJson(jobJson))
              .toList();
        });
      } else {
        print("❌ Failed to load saved jobs: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching saved jobs: ${e.toString()}");
    }
  }

  Future<void> fetchAppliedJobs() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          errorMessage = "Could not get authentication token";
          isLoading = false;
        });
        return;
      }

      print("🔄 Fetching applied jobs...");

      final response = await http.get(
        Uri.parse('$baseUrl2/student/fetchappliedjobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          print("✅ Applied jobs: $data");
          // Store full applications data
          appliedApplications = data['applications'] ?? [];

          // ✅ Extract and convert job details from applications to Job objects
          appliedJobs = (data['applications'] as List)
              .map((app) => app['job'])
              .where((job) => job != null)
              .map((jobJson) => Job.fromJson(jobJson))
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load applied jobs: ${response.statusCode}';
          isLoading = false;
        });
        print("❌ Failed to load applied jobs: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print("❌ Error fetching applied jobs: ${e.toString()}");
    }
  }

  // Helper to get application status for a job
  String getApplicationStatus(String jobId) {
    try {
      final app = appliedApplications.firstWhere(
        (application) => application['job']?['_id'] == jobId,
        orElse: () => null,
      );
      if (app != null && app['status'] != null) {
        return app['status'].toString();
      }
    } catch (e) {
      print("❌ Error getting status: $e");
    }
    return 'applied';
  }

  // Helper to get match score for a job
  int? getMatchScore(String jobId) {
    try {
      final app = appliedApplications.firstWhere(
        (application) => application['job']?['_id'] == jobId,
        orElse: () => null,
      );
      if (app != null && app['matchScore'] != null) {
        return app['matchScore'] as int;
      }
    } catch (e) {
      print("❌ Error getting match score: $e");
    }
    return null;
  }

  // ✅ Added isApplied parameter with default value
  List<Map<String, dynamic>> jobsToDisplayFormat(
    List<Job> jobs, {
    bool isApplied = false,
  }) {
    return jobs.asMap().entries.map((entry) {
      int index = entry.key;
      Job job = entry.value;

      // Create recruiter map - handle both populated and unpopulated cases
      Map<String, dynamic>? recruiterMap;
      if (job.recruiterDetails != null) {
        // Recruiter is populated
        recruiterMap = job.recruiterDetails;
      } else if (job.recruiter is String && job.recruiter.isNotEmpty) {
        // Recruiter is just an ID - create minimal map
        recruiterMap = {
          'id': job.recruiter,
          'name': 'Unknown',
          'email': 'N/A',
          'firebaseId': job.recruiter, // Use the ID as fallback
          'designation': 'N/A',
          'company': {'name': 'Unknown Company'},
        };
      }

      // ✅ Get status and match score if this is an applied job
      Map<String, dynamic> result = {
        'jobTitle': job.title,
        'id': job.id,
        'jobType': job.jobType,
        'companyName': job.recruiterName.isNotEmpty
            ? job.recruiterName
            : 'Company',
        'location': job.preferences.location.isNotEmpty
            ? job.preferences.location
            : 'Location not specified',
        'experienceLevel': job.preferences.minExperience > 0
            ? '${job.preferences.minExperience}+ years'
            : 'Entry level',
        'requirements': job.preferences.skills.isNotEmpty
            ? job.preferences.skills
            : ['Skills not specified'],
        'websiteUrl': job.applicationLink ?? 'Apply via app',
        'initialColorIndex': index % 3,
        'description': job.description,
        'salaryRange':
            '₹${job.salaryRange.min.toInt()}k - ₹${job.salaryRange.max.toInt()}k',
        'jobId': job.id,
        'jobType': job.jobType,
        'college': job.college ?? 'N/A',
        'tagLabel': job.jobType == 'on-campus'
            ? 'On Campus'
            : job.jobType == 'external'
            ? 'External'
            : 'In House',
        'tagColor': job.jobType == 'on-campus'
            ? const Color(0xFF6C63FF)
            : job.jobType == 'external'
            ? const Color(0xFF00BFA6)
            : const Color(0xFFFFB347),
        'employmentType': job.employmentType,
        'rolesAndResponsibilities':
            job.rolesAndResponsibilities?.isNotEmpty == true
            ? job.rolesAndResponsibilities
            : 'Not specified',
        'perks': job.perks?.isNotEmpty == true ? job.perks : 'Not specified',
        'details': job.details?.isNotEmpty == true
            ? job.details
            : 'Not specified',
        'noOfOpenings': job.noOfOpenings.toString(),
        'duration': job.duration?.isNotEmpty == true
            ? job.duration
            : 'Not specified',
        'skills': job.preferences.skills,
        'mode': job.mode.isNotEmpty ? job.mode : 'Not specified',
        'stipend': job.stipend != null ? '₹${job.stipend}' : 'Not specified',
        'recruiter': recruiterMap,
      };

      // ✅ Add application-specific fields if this is an applied job
      if (isApplied) {
        result['applicationStatus'] = getApplicationStatus(job.id);
        result['matchScore'] = getMatchScore(job.id);
      }

      return result;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchAllData,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: fetchAllData,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: CustomButton(
                            onPressed: () => Navigator.pop(context),
                            buttonIcon: Icons.arrow_back,
                          ),
                        ),
                        SizedBox(width: 0),
                        Expanded(
                          child: CustomAppBar(
                            searchController: TextEditingController(),
                            onSearchSubmit: (value) {},
                            onChatPressed: () {},
                            onNotificationPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomCarouselSection(
                      subtitle: 'Saved Jobs',
                      title: 'Your saved jobs',
                      filters: ['all', 'company', 'on-campus', 'external'],
                      selectedFilter: 'all',
                      onFilterTap: (filter) {
                        // Implement filter logic here
                      },
                      items: jobsToDisplayFormat(savedJobs),
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              items: jobsToDisplayFormat(savedJobs),
                              statusPage: true,
                            ),
                          ),
                        );
                      },
                      onCarouselTap: (String p1) {},
                      onItemTap: (job) {
                        print("---- Navigating to Carddetails ----");
                        print("Job Title: ${job['jobTitle']}");
                        print("Company Name: ${job['companyName']}");
                        print("Location: ${job['location']}");
                        print("Website URL: ${job['websiteUrl']}");
                        print("Job Type: ${job['jobType']}");
                        print("tagLabel: ${job['tagLabel']}");
                        print("-----------------------------------");

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Carddetails(
                              jobTitle: job['jobTitle'] ?? 'No Title',
                              companyName:
                                  job['companyName'] ?? 'Unknown Company',
                              location:
                                  job['location'] ?? 'Location not specified',
                              experienceLevel:
                                  job['experienceLevel'] ?? 'Not specified',
                              requirements: job['requirements'] != null
                                  ? List<String>.from(job['requirements'])
                                  : <String>[],
                              websiteUrl: job['websiteUrl'] ?? '',
                              tagLabel: job['tagLabel'],
                              employmentType:
                                  job['employmentType'] ?? 'Not specified',
                              rolesAndResponsibilities:
                                  job['description'] ??
                                  'No description available',
                              duration: job['duration'] ?? 'Not specified',
                              stipend:
                                  job['stipend']?.toString() ?? 'Not specified',
                              details:
                                  job['description'] ?? 'No details available',
                              noOfOpenings:
                                  job['noOfOpenings']?.toString() ??
                                  'Not specified',
                              mode: job['mode'] ?? 'Not specified',
                              skills: job['requirements'] != null
                                  ? List<String>.from(job['requirements'])
                                  : <String>[],
                              id: job['jobId'] ?? '',
                              jobType: job['jobType'] ?? 'Not specified',
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    CustomCarouselSection(
                      subtitle: 'applied jobs',
                      title: 'Your applied jobs',
                      filters: [
                        'all',
                        'applied',
                        'shortlisted',
                        'rejected',
                        'hired',
                      ],
                      selectedFilter: 'all',
                      onFilterTap: (filter) => {},
                      items: jobsToDisplayFormat(
                        appliedJobs,
                        isApplied: true,
                      ), // ✅ Now works correctly
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              items: jobsToDisplayFormat(
                                appliedJobs,
                                isApplied: true,
                              ),
                              statusPage: true,
                            ),
                          ),
                        );
                      },
                      onCarouselTap: (String p1) {},
                      onItemTap: (job) {
                        print("---- Navigating to Carddetails ----");
                        print("Job ID: ${job['jobId'] ?? 'N/A'}");
                        print("Job Title: ${job['jobTitle'] ?? 'N/A'}");
                        print("Company Name: ${job['companyName'] ?? 'N/A'}");
                        print("Location: ${job['location'] ?? 'N/A'}");
                        print(
                          "Experience Level: ${job['experienceLevel'] ?? 'N/A'}",
                        );
                        print(
                          "Employment Type: ${job['employmentType'] ?? 'N/A'}",
                        );
                        print("Mode: ${job['mode'] ?? 'N/A'}");
                        print("Job Type: ${job['jobType'] ?? 'N/A'}");
                        print("Tag Label: ${job['tagLabel'] ?? 'N/A'}");
                        print("Website URL: ${job['websiteUrl'] ?? 'N/A'}");
                        print("Duration: ${job['duration'] ?? 'N/A'}");
                        print("Stipend: ${job['stipend'] ?? 'N/A'}");
                        print(
                          "No of Openings: ${job['noOfOpenings'] ?? 'N/A'}",
                        );
                        print("Match Score: ${job['matchScore'] ?? 'N/A'}");
                        print(
                          "Application Status: ${job['applicationStatus'] ?? 'N/A'}",
                        );
                        print(
                          "Roles & Responsibilities: ${job['description'] ?? 'N/A'}",
                        );
                        print(
                          "Details: ${job['details'] ?? job['description'] ?? 'N/A'}",
                        );

                        // Safely print requirements and skills as lists
                        print(
                          "Requirements: ${job['requirements'] != null ? job['requirements'].join(', ') : 'None'}",
                        );
                        print(
                          "Skills: ${job['skills'] != null ? job['skills'].join(', ') : 'None'}",
                        );

                        // Print recruiter info if available
                        if (job['recruiter'] != null) {
                          print("Recruiter Info:");
                          print("  Name: ${job['recruiter']['name'] ?? 'N/A'}");
                          print(
                            "  Email: ${job['recruiter']['email'] ?? 'N/A'}",
                          );
                          print(
                            "  Company: ${job['recruiter']['firebaseId'] ?? 'N/A'}",
                          );
                        } else {
                          print("Recruiter Info: Not available");
                        }

                        print("-----------------------------------");

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Carddetails(
                              jobTitle: job['jobTitle'] ?? 'No Title',
                              companyName:
                                  job['companyName'] ?? 'Unknown Company',
                              location:
                                  job['location'] ?? 'Location not specified',
                              experienceLevel:
                                  job['experienceLevel'] ?? 'Not specified',
                              requirements: job['requirements'] != null
                                  ? List<String>.from(job['requirements'])
                                  : <String>[],
                              websiteUrl: job['websiteUrl'] ?? '',
                              tagLabel: job['tagLabel'],
                              employmentType:
                                  job['employmentType'] ?? 'Not specified',
                              rolesAndResponsibilities:
                                  job['description'] ??
                                  'No description available',
                              duration: job['duration'] ?? 'Not specified',
                              stipend:
                                  job['stipend']?.toString() ?? 'Not specified',
                              details:
                                  job['description'] ?? 'No details available',
                              noOfOpenings:
                                  job['noOfOpenings']?.toString() ??
                                  'Not specified',
                              mode: job['mode'] ?? 'Not specified',
                              skills: job['skills'] != null
                                  ? List<String>.from(job['skills'])
                                  : <String>[],
                              id: job['jobId'] ?? '',
                              jobType: job['jobType'] ?? 'Not specified',
                              recruiter: job["recruiter"],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
