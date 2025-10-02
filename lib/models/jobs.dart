import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/core/constants/app_constants.dart';

// Job model to match your backend schema
class Job {
  final String id;
  final String title;
  final String description;
  final String recruiter;
  final String college;
  final String jobType;
  final SalaryRange salaryRange;
  final Preferences preferences;
  final String? applicationLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.recruiter,
    required this.college,
    required this.jobType,
    required this.salaryRange,
    required this.preferences,
    this.applicationLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recruiter: json['recruiter'] ?? '',
      college: json['college'] ?? '',
      jobType: json['jobType'] ?? 'company',
      salaryRange: SalaryRange.fromJson(json['salaryRange'] ?? {}),
      preferences: Preferences.fromJson(json['preferences'] ?? {}),
      applicationLink: json['applicationLink'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // get jobType => null;

  // get applicationLink => null;

  // get college => null;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'recruiter': recruiter,
      'college': college,
      'jobType': jobType,
      'salaryRange': salaryRange.toJson(),
      'preferences': preferences.toJson(),
      'applicationLink': applicationLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SalaryRange {
  final double min;
  final double max;

  SalaryRange({required this.min, required this.max});

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max};
  }
}

class Preferences {
  final List<String> skills;
  final int minExperience;
  final String education;
  final String location;

  Preferences({
    required this.skills,
    required this.minExperience,
    required this.education,
    required this.location,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      skills: List<String>.from(json['skills'] ?? []),
      minExperience: json['minExperience'] ?? 0,
      education: json['education'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'minExperience': minExperience,
      'education': education,
      'location': location,
    };
  }
}

class JobProvider with ChangeNotifier {
  static const String baseUrl = AppConstants.studentBaseUrl;

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchStrategy = '';
  List<String> _userSkills = [];
  bool _hasUserSkills = false;
  bool _isRequestInProgress = false;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchStrategy => _searchStrategy;
  List<String> get userSkills => _userSkills;
  bool get hasUserSkills => _hasUserSkills;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchJobs() async {
    if (_isRequestInProgress || _isLoading) {
      print("🚫 Request already in progress, skipping...");
      return;
    }

    _isRequestInProgress = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = "User not logged in";
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        _errorMessage = "Could not get authentication token";
        return;
      }

      print("🔄 Fetching jobs with token...");

      // Fetch both opportunities and recruiter jobs in parallel
      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/college/opportunities'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ),
        http.get(
          Uri.parse('$baseUrl/recruiter/jobs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ),
      ]);

      final response = responses[0];
      final response2 = responses[1];

      print("📡 Opportunities Response Status: ${response.statusCode}");
      print("📡 Recruiter Jobs Response Status: ${response2.statusCode}");

      List<Job> allJobs = [];

      // Process opportunities response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> opportunitiesData =
              responseData['opportunities'] ?? [];
          allJobs.addAll(
            opportunitiesData.map((jobJson) => Job.fromJson(jobJson)).toList(),
          );

          _searchStrategy = responseData['searchStrategy'] ?? '';
          _userSkills = List<String>.from(responseData['userSkills'] ?? []);
          _hasUserSkills = responseData['hasUserSkills'] ?? false;

          print("✅ Opportunities fetched: ${opportunitiesData.length}");
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        return;
      } else if (response.statusCode == 404) {
        _errorMessage =
            'Student profile not found. Please complete your profile setup.';
        return;
      }

      // Process recruiter jobs response
      if (response2.statusCode == 200) {
        final Map<String, dynamic> responseData2 = json.decode(response2.body);

        if (responseData2['success'] == true) {
          final List<dynamic> recruiterJobsData =
              responseData2['opportunities'] ?? [];
          allJobs.addAll(
            recruiterJobsData.map((jobJson) => Job.fromJson(jobJson)).toList(),
          );

          print("✅ Recruiter jobs fetched: ${recruiterJobsData.length}");
        }
      }

      _jobs = allJobs;

      print("📊 Total jobs fetched: ${_jobs.length}");
      print("🎯 Search strategy: $_searchStrategy");
      print("🛠️ User skills: $_userSkills");
      print("💡 Has user skills: $_hasUserSkills");

      _errorMessage = null;
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      _errorMessage =
          'Network error: Please check your connection and try again.';
    } finally {
      _isLoading = false;
      _isRequestInProgress = false;
      notifyListeners();
    }
  }

  Future<void> applyJob(String jobId, String jobType) async {
    print("🔄 Starting job application...");
    print("📋 Job ID: $jobId");
    print("🏢 Job Type: $jobType");

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = "User not logged in";
        notifyListeners();
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        _errorMessage = "Could not get authentication token";
        notifyListeners();
        return;
      }

      // Updated URL to include jobType
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
        _errorMessage = null;
      } else {
        print("❌ Application failed with status: ${response.statusCode}");
        final errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ?? "Failed to apply: ${response.statusCode}";
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      _errorMessage = "Error applying to job: $e";
    }

    notifyListeners();
  }

  Future<void> createJob(Job job) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = "User not logged in";
        notifyListeners();
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        _errorMessage = "Could not get authentication token";
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(job.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final newJob = Job.fromJson(responseData);
        _jobs.add(newJob);
        _errorMessage = null;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ??
            'Failed to create job: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error creating job: $e';
    }
    notifyListeners();
  }

  Map<String, int> getJobStatistics() {
    final stats = <String, int>{
      'total': _jobs.length,
      'on-campus': 0,
      'company': 0,
      'external': 0,
    };

    for (final job in _jobs) {
      stats[job.jobType] = (stats[job.jobType] ?? 0) + 1;
    }

    return stats;
  }

  List<Job> getJobsByType(String jobType) {
    return _jobs.where((job) => job.jobType == jobType).toList();
  }

  List<Job> getSkillMatchedJobs() {
    if (_userSkills.isEmpty) return [];

    return _jobs.where((job) {
      final jobSkills = job.preferences.skills
          .map((s) => s.toLowerCase())
          .toList();
      final userSkillsLower = _userSkills.map((s) => s.toLowerCase()).toList();

      return jobSkills.any(
        (skill) =>
            userSkillsLower.any((userSkill) => skill.contains(userSkill)),
      );
    }).toList();
  }
}
