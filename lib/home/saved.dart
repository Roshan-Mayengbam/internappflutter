import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/custom_app_bar.dart';
import 'package:internappflutter/core/components/custom_button.dart';
import 'package:internappflutter/core/components/jobs_page/custom_carousel_section.dart';
import 'package:internappflutter/package/ViewMores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cardDetails.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";
  List<dynamic> savedJobs = [];
  List<dynamic> appliedJobs = [];
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
          savedJobs = data['saves'] ?? [];
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
          // Extract job details from applications
          appliedJobs = (data['applications'] as List)
              .map((app) => app['job'])
              .where((job) => job != null)
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

  // Helper to get full job data by ID
  dynamic getFullJobData(String jobId, List<dynamic> jobsList) {
    try {
      return jobsList.firstWhere(
        (job) => job['_id'] == jobId,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> convertJobsToItems(List<dynamic> jobs) {
    return jobs.where((job) => job != null).map((job) {
      try {
        // Safe getter helper
        String safeGet(dynamic value, [String defaultValue = 'N/A']) {
          if (value == null) return defaultValue;
          return value.toString();
        }

        // Handle company name - could be object or string
        String companyName = 'N/A';
        if (job['company'] != null) {
          if (job['company'] is Map) {
            companyName = safeGet(job['company']['name']);
          } else if (job['company'] is String) {
            companyName = 'Company'; // ObjectId not populated
          }
        } else if (job['college'] != null) {
          companyName = safeGet(job['college']);
        }

        // Handle preferences safely
        String location = 'N/A';
        String experienceLevel = 'N/A';
        if (job['preferences'] != null && job['preferences'] is Map) {
          location = safeGet(job['preferences']['location']);
          if (job['preferences']['minExperience'] != null) {
            experienceLevel = '${job['preferences']['minExperience']}+ years';
          }
        }

        // Handle salary range safely
        String salaryRange = 'N/A';
        if (job['salaryRange'] != null && job['salaryRange'] is Map) {
          var min = job['salaryRange']['min'];
          var max = job['salaryRange']['max'];
          if (min != null && max != null) {
            salaryRange = '${min.toString()} - ${max.toString()}';
          }
        }

        // Extract additional fields for navigation
        List<String> requirements = [];
        if (job['requirements'] != null && job['requirements'] is List) {
          requirements = (job['requirements'] as List)
              .map((e) => e.toString())
              .toList();
        } else if (job['skills'] != null && job['skills'] is List) {
          requirements = (job['skills'] as List)
              .map((e) => e.toString())
              .toList();
        }

        return {
          "jobId": safeGet(job['_id'], ''),
          "jobTitle": safeGet(job['title']),
          "companyName": companyName,
          "location": location,
          "experienceLevel": experienceLevel,
          "salaryRange": salaryRange,
          "jobType": safeGet(job['jobType']),
          "description": safeGet(job['description'], ''),
          "requirements": requirements,
          "websiteUrl": safeGet(job['websiteUrl'], ''),
          "tagLabel": job['tagLabel'],
          "duration": safeGet(job['duration'], 'Not specified'),
          "stipend": job['stipend']?.toString() ?? 'Not specified',
          "noOfOpenings": safeGet(job['noOfOpenings'], 'Not specified'),
          "mode": safeGet(job['mode'], 'Not specified'),
        };
      } catch (e) {
        print("❌ Error converting job: $e");
        print("❌ Job data: $job");
        // Return a placeholder if conversion fails
        return {
          "jobId": '',
          "jobTitle": 'Error loading job',
          "companyName": 'N/A',
          "location": 'N/A',
          "experienceLevel": 'N/A',
          "salaryRange": 'N/A',
          "jobType": 'N/A',
          "description": '',
          "requirements": [],
          "websiteUrl": '',
          "tagLabel": null,
          "duration": 'Not specified',
          "stipend": 'Not specified',
          "noOfOpenings": 'Not specified',
          "mode": 'Not specified',
        };
      }
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
                    SizedBox(height: 20),
                    CustomCarouselSection(
                      subtitle: 'Saved Jobs',
                      title: 'Your saved jobs',
                      filters: ['all', 'company', 'on-campus', 'external'],
                      selectedFilter: 'all',
                      onFilterTap: (filter) {
                        // Implement filter logic here
                      },
                      items: convertJobsToItems(savedJobs),
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              items: convertJobsToItems(savedJobs),
                              statusPage: true,
                            ),
                          ),
                        );
                      },
                      onCarouselTap: (String p1) {},

                      // Replace the onItemTap callback in both CustomCarouselSection widgets with this:
                      onItemTap: (job) {
                        print("---- Navigating to Carddetails ----");
                        print("Job Title: ${job['jobTitle']}");
                        print("Company Name: ${job['companyName']}");
                        print("Location: ${job['location']}");
                        print("Website URL: ${job['websiteUrl']}");
                        print("Job Type: ${job['jobType']}");
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
                      filters: ['all', 'applied', 'interviewing', 'offered'],
                      selectedFilter: 'all',
                      onFilterTap: (filter) => {},
                      items: convertJobsToItems(appliedJobs),
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              items: convertJobsToItems(appliedJobs),
                              statusPage: true,
                            ),
                          ),
                        );
                      },
                      onItemTap: (job) {
                        print("---- Navigating to Carddetails ----");
                        print("Job Title: ${job['jobTitle']}");
                        print("Company Name: ${job['companyName']}");
                        print("Location: ${job['location']}");
                        print("Website URL: ${job['websiteUrl']}");
                        print("Job Type: ${job['jobType']}");
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
                              skills: job['requirements'] != null
                                  ? List<String>.from(job['requirements'])
                                  : <String>[],
                              id: job['jobId'] ?? '',
                              jobType: job['jobType'] ?? 'Not specified',
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
