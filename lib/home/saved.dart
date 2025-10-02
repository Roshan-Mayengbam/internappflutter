import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/custom_app_bar.dart';
import 'package:internappflutter/core/components/custom_button.dart';
import 'package:internappflutter/core/components/jobs_page/custom_carousel_section.dart';
import 'package:internappflutter/core/constants/app_constants.dart';
import 'package:internappflutter/features/data/models/job_response_model.dart';
import 'package:internappflutter/features/domain/entities/job_response.dart';
import 'package:internappflutter/package/ViewMores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<Job> savedJobs = [];
  List<Job> appliedJobs = [];
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
        Uri.parse(AppConstants.baseUrl + "saves"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jobList = data['saves'] ?? [];
        setState(() {
          print("✅ Saved jobs: $data");
          savedJobs = parseJobs(jobList);
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
        Uri.parse('http://172.31.223.157:3000/student/fetchappliedjobs'),
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
          final List<dynamic> jobList = (data['applications'] as List)
              .map((app) => app['job'])
              .where((job) => job != null)
              .toList();
          appliedJobs = parseJobs(jobList);
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

  /// Parses a list of raw job JSON objects into a list of Job entities.
  List<Job> parseJobs(List<dynamic> jobs) {
    return jobs.where((jobJson) => jobJson != null).map((jobJson) {
      try {
        // Use the existing JobModel to safely parse the data
        return JobModel.fromJson(jobJson);
      } catch (e) {
        print("❌ Error parsing job: $e");
        print("❌ Job data: $jobJson");
        // Return a placeholder Job object on failure
        return const Job(
          id: '',
          title: 'Error: Could not load job',
          description: '',
          recruiter: Recruiter(
            id: '',
            name: 'N/A',
            isVerified: false,
            company: Company(id: '', name: 'N/A'),
          ),
          jobType: 'N/A',
          salaryRange: SalaryRange(min: 0, max: 0),
        );
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
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: CustomButton(
                            onPressed: () => print("hello"),
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
                      items: savedJobs,
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              // The ViewMores widget might need to be updated
                              // to accept List<Job> as well.
                              items: [], // Placeholder
                              statusPage: true,
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
                      items: appliedJobs,
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMores(
                              items: [], // Placeholder
                              statusPage: true,
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
