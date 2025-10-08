import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Job model to match your backend schema

class Job {
  final String id;
  final String title;
  final String description;
  final String recruiter;
  final String? college;
  final String jobType;
  final String employmentType;
  final String? rolesAndResponsibilities;
  final String? perks;
  final String? details;
  final int noOfOpenings;
  final String? duration;
  final String mode;
  final int? stipend;
  final SalaryRange salaryRange;
  final Preferences preferences;
  final String? applicationLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool applied;
  final List<String> skills;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.recruiter,
    this.college,
    required this.jobType,
    required this.employmentType,
    this.rolesAndResponsibilities,
    this.perks,
    this.details,
    required this.noOfOpenings,
    this.duration,
    required this.mode,
    this.stipend,
    required this.salaryRange,
    required this.preferences,
    this.applicationLink,
    required this.createdAt,
    required this.updatedAt,
    this.applied = false,
    this.skills = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Safely extract skills list
    List<String> extractedSkills = [];
    if (json['preferences']?['skills'] != null) {
      extractedSkills = (json['preferences']['skills'] as List)
          .map(
            (skill) =>
                skill is Map ? skill['type'].toString() : skill.toString(),
          )
          .toList();
    }

    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recruiter: json['recruiter']?.toString() ?? '',
      college: json['college'],
      jobType: json['jobType'] ?? 'company', // ✅ explicitly mapped
      employmentType: json['employmentType'] ?? 'full-time',
      rolesAndResponsibilities: json['rolesAndResponsibilities'],
      perks: json['perks'],
      details: json['details'],
      noOfOpenings: (json['noOfOpenings'] is int)
          ? json['noOfOpenings']
          : int.tryParse(json['noOfOpenings'].toString()) ?? 1,
      duration: json['duration'],
      mode: json['mode'] ?? 'on-site',
      stipend: json['stipend'] != null
          ? int.tryParse(json['stipend'].toString())
          : null,
      salaryRange: SalaryRange.fromJson(json['salaryRange'] ?? {}),
      preferences: Preferences.fromJson(json['preferences'] ?? {}),
      applicationLink: json['applicationLink'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      applied: json['applied'] ?? false,
      skills: extractedSkills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'recruiter': recruiter,
      'college': college,
      'jobType': jobType, // ✅ included explicitly
      'employmentType': employmentType,
      'rolesAndResponsibilities': rolesAndResponsibilities,
      'perks': perks,
      'details': details,
      'noOfOpenings': noOfOpenings,
      'duration': duration,
      'mode': mode,
      'stipend': stipend,
      'salaryRange': salaryRange.toJson(),
      'preferences': preferences.toJson(),
      'applicationLink': applicationLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'applied': applied,
      'skills': skills,
    };
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
    // Extract skills array safely
    List<String> extractedSkills = [];
    if (json['skills'] != null) {
      extractedSkills = (json['skills'] as List)
          .map(
            (skill) =>
                skill is Map ? skill['type'].toString() : skill.toString(),
          )
          .toList();
    }

    return Preferences(
      skills: extractedSkills,
      minExperience: (json['minExperience'] is int)
          ? json['minExperience']
          : int.tryParse(json['minExperience']?.toString() ?? '0') ?? 0,
      education: json['education'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills.map((s) => {'type': s}).toList(),
      'minExperience': minExperience,
      'education': education,
      'location': location,
    };
  }
}

class SalaryRange {
  final double min;
  final double max;

  SalaryRange({required this.min, required this.max});

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: _toDouble(json['min']),
      max: _toDouble(json['max']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max};
  }
}

class JobProvider with ChangeNotifier {
  static const String baseUrl =
      'https://hyrup-730899264601.asia-south1.run.app';

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
        print(responseData);

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
        print(responseData2);

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
