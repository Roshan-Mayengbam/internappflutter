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

  // final String baseUrl3 = "http://10.168.89.157:3000";

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
          List<dynamic> savesData = data['saves'] ?? [];
          savedJobs = savesData
              .map((jobJson) => Job.fromJson(jobJson))
              .toList();

          // ✅ REMOVED ALL SORTING - backend already sorted by savedAt
          print("✅ Loaded ${savedJobs.length} saved jobs");
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
        Uri.parse('$baseUrl/student/fetchappliedjobs'),
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

          // ✅ Applications are already sorted by backend (createdAt descending)
          // No need to sort again since backend does it
          appliedJobs = (appliedApplications)
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
        'companyName':
            job.recruiterDetails?['company']?['name']?.isNotEmpty == true
            ? job.recruiterDetails?['company']?['name']
            : job.recruiterName.isNotEmpty
            ? job.recruiterName
            : 'Company',
        'about':
            job.recruiterDetails?['company']?['description']?.isNotEmpty == true
            ? job.recruiterDetails?['company']?['description']
            : job.recruiterName.isNotEmpty
            ? job.recruiterName
            : 'description not available',
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
        // ignore: equal_keys_in_map
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            onPressed: () => Navigator.pop(context),
                            buttonIcon: Icons.arrow_back,
                          ),
                        ),
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
                    const SizedBox(height: 20),

                    // else
                    CustomCarouselSection(
                      subtitle: 'Saved Jobs',
                      title: 'Your saved jobs',
                      filters: ['all', 'company', 'on-campus', 'external'],
                      selectedFilter: 'all',
                      isAppliedSection: false,
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
                              isAppliedSection: false,
                              statusPage: true,
                            ),
                          ),
                        );
                      },
                      onCarouselTap: (String p1) {},
                      onItemTap: (job) {
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
                              about:
                                  job['about'] ?? 'description not available',
                              salaryRange:
                                  job['salaryRange'] ?? 'Not specified',
                              perks: [],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    CustomCarouselSection(
                      subtitle: 'Applied Jobs',
                      title: 'Your applied jobs',
                      filters: [
                        'all',
                        'applied',
                        'shortlisted',
                        'rejected',
                        'hired',
                      ],
                      selectedFilter: 'all',
                      onFilterTap: (filter) {},
                      items: jobsToDisplayFormat(appliedJobs, isApplied: true),
                      isAppliedSection: true,
                      statusPage: true,
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
                              isAppliedSection: true,
                            ),
                          ),
                        );
                      },
                      onItemTap: (job) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Carddetails(
                              jobTitle: job['jobTitle'] ?? 'No Title',
                              companyName:
                                  job['companyName'] ?? 'Unknown Company',
                              about:
                                  job['about'] ?? 'description not available',
                              location:
                                  job['location'] ?? 'Location not specified',
                              experienceLevel:
                                  job['experienceLevel'] ?? 'Not specified',
                              requirements: job['requirements'] != null
                                  ? List<String>.from(job['requirements'])
                                  : <String>[],
                              websiteUrl: job['websiteUrl'] ?? '',
                              tagLabel: job['tagLabel'],
                              employmentType: job['jobType'] ?? 'Not specified',
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
                              salaryRange:
                                  job['salaryRange'] ?? 'Not specified',
                              perks: [],
                            ),
                          ),
                        );
                      },
                      onCarouselTap: (String p1) {},
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
