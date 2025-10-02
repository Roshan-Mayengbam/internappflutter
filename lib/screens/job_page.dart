import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:internappflutter/core/components/custom_app_bar.dart';
import 'package:internappflutter/core/components/jobs_page/custom_carousel_section.dart';
import 'package:internappflutter/features/data/datasources/job_response_remote_datasource.dart';
import 'package:internappflutter/features/domain/entities/job_response.dart';
import 'package:internappflutter/features/domain/usecases/get_jobs.dart';

import '../features/core/errors/failiure.dart';
import '../features/data/repositories/job_repository_impl.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  // State variables to manage UI
  bool _isLoading = true;
  List<Job> _jobs = [];
  String? _errorMessage;

  final List<String> jobFilters = [
    'Featured',
    'Live',
    'Upcoming',
    'Always Open',
    'Full-Time',
    'Part-Time',
    'Internship',
  ];
  String selectedJobFilter = 'Featured';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  /// Fetches job data directly without using Provider.
  Future<void> _fetchJobs() async {
    // 1. Manually create the dependency chain
    final client = http.Client();
    final auth = FirebaseAuth.instance;
    final remoteDataSource = JobRemoteDataSourceImpl(
      client: client,
      auth: auth,
    );
    final repository = JobRepositoryImpl(remoteDataSource: remoteDataSource);
    final getJobsUseCase = GetJobs(repository);

    // 2. Execute the use case
    try {
      final result = await getJobsUseCase(const GetJobsParams(page: 1));

      if (mounted) {
        result.fold(
          (failure) {
            // More detailed error logging
            print("❌ Data fetching failed: $failure");
            if (failure is ServerFailure) {
              print("❌ Server Failure Message: ${failure.message}");
              setState(() {
                _errorMessage = "Server Error: ${failure.message}";
                _isLoading = false;
              });
            } else {
              setState(() {
                _errorMessage = "An error occurred: $failure";
                _isLoading = false;
              });
            }
          },
          (jobResponse) {
            setState(() {
              _jobs = jobResponse.jobs;
              _isLoading = false;
            });
          },
        );
      }
    } catch (e, stacktrace) {
      // Catch any unexpected parsing exceptions
      print("❌ Exception in _fetchJobs: $e");
      print("❌ Stacktrace: $stacktrace");
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred while parsing data.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Custom App Bar
            CustomAppBar(
              searchController: _searchController,
              onSearchSubmit: (query) {
                print("Search submitted: $query");
              },
              onChatPressed: () {
                print("Chat button pressed");
              },
              onNotificationPressed: () {
                print("Notification button pressed");
              },
            ),
            const SizedBox(height: 30),
            // Top Job Picks Section - Build UI based on local state
            _buildJobSection(),
            const SizedBox(height: 30),
            // You can add other sections here
          ],
        ),
      ),
    );
  }

  /// Builds the job carousel section based on the current state.
  Widget _buildJobSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    return CustomCarouselSection(
      title: 'Top job picks for you',
      subtitle:
          'Based on your profile, preference and activity like applies, searches and saves',
      filters: jobFilters,
      selectedFilter: selectedJobFilter,
      onFilterTap: (filter) {
        setState(() {
          selectedJobFilter = filter;
        });
      },
      onViewMore: () {
        print("Pressed View more in jobs display");
      },
      items: _jobs, // Use jobs from the local state
    );
  }
}
