import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Job model to match your backend schema

class Job {
  final String id;
  final String title;
  final String jobType;
  final dynamic recruiter;
  final String description;
  final String? applicationLink;
  final String employmentType;
  final String? rolesAndResponsibilities;
  final List<String> perks; // ✅ Changed from String? to List<String>
  final String? details;
  final int noOfOpenings;
  final String? duration;
  final String mode;
  final double? stipend;
  final String? college;
  final JobPreferences preferences;
  final SalaryRange salaryRange;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool applied;
  final List<String> skills;

  Job({
    required this.id,
    required this.title,
    required this.jobType,
    required this.recruiter,
    required this.description,
    this.applicationLink,
    required this.employmentType,
    this.rolesAndResponsibilities,
    this.perks = const [], // ✅ Changed default value
    this.details,
    required this.noOfOpenings,
    this.duration,
    required this.mode,
    required this.stipend,
    this.college,
    required this.preferences,
    required this.salaryRange,
    required this.createdAt,
    required this.updatedAt,
    this.applied = false,
    this.skills = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<String> extractedSkills = [];
    if (json['preferences']?['skills'] != null) {
      extractedSkills = (json['preferences']['skills'] as List)
          .map(
            (skill) =>
                skill is Map ? skill['type'].toString() : skill.toString(),
          )
          .toList();
    }

    // ✅ Parse perks as list
    List<String> extractedPerks = [];
    if (json['perks'] != null) {
      if (json['perks'] is List) {
        // If perks is already a list
        extractedPerks = (json['perks'] as List)
            .map((perk) => perk.toString())
            .where((perk) => perk.isNotEmpty)
            .toList();
      } else if (json['perks'] is String) {
        // If perks is a string with bullet points, split it
        String perksString = json['perks'] as String;
        extractedPerks = perksString
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) {
              // Remove bullet points (•, -, *, etc.)
              return line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
            })
            .where((line) => line.isNotEmpty)
            .toList();
      }
    }

    return Job(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      jobType: json['jobType'] ?? 'company',
      recruiter: json['recruiter'],
      description: json['description'] ?? '',
      applicationLink: json['applicationLink'],
      employmentType: json['employmentType'] ?? 'full-time',
      rolesAndResponsibilities: json['rolesAndResponsibilities'],
      perks: extractedPerks, // ✅ Use extracted perks list
      details: json['details'],
      noOfOpenings: (json['noOfOpenings'] is int)
          ? json['noOfOpenings']
          : int.tryParse(json['noOfOpenings'].toString()) ?? 1,
      duration: json['duration'],
      mode: json['mode'] ?? 'on-site',
      stipend: json['stipend'] != null
          ? (json['stipend'] is int
                ? (json['stipend'] as int).toDouble()
                : double.tryParse(json['stipend'].toString()))
          : null,
      college: json['college'],
      preferences: JobPreferences.fromJson(json['preferences'] ?? {}),
      salaryRange: SalaryRange.fromJson(json['salaryRange'] ?? {}),
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
      'jobType': jobType,
      'recruiter': recruiter,
      'description': description,
      'applicationLink': applicationLink,
      'employmentType': employmentType,
      'rolesAndResponsibilities': rolesAndResponsibilities,
      'perks': perks, // ✅ Send as list
      'details': details,
      'noOfOpenings': noOfOpenings,
      'duration': duration,
      'mode': mode,
      'stipend': stipend,
      'college': college,
      'preferences': preferences.toJson(),
      'salaryRange': salaryRange.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'applied': applied,
      'skills': skills,
    };
  }

  // ✅ Helper method to get formatted perks string
  String get perksFormatted {
    if (perks.isEmpty) return 'No perks listed';
    return perks.map((perk) => '• $perk').join('\n');
  }

  // ===== EXISTING HELPER METHODS =====

  bool get isRecruiterPopulated => recruiter is Map<String, dynamic>;

  Map<String, dynamic>? get recruiterDetails {
    if (recruiter is Map<String, dynamic>) {
      return recruiter as Map<String, dynamic>;
    }
    return null;
  }

  String get recruiterId {
    if (recruiter is String) {
      return recruiter as String;
    } else if (recruiter is Map<String, dynamic>) {
      return recruiter['_id'] ?? recruiter['id'] ?? '';
    }
    return '';
  }

  String get recruiterName {
    if (recruiter is Map<String, dynamic>) {
      return recruiter['name'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  // ===== COMPANY HELPER METHODS =====

  Map<String, dynamic>? get companyInfo {
    if (recruiter is Map<String, dynamic>) {
      final rec = recruiter as Map<String, dynamic>;
      if (rec.containsKey('company') && rec['company'] is Map) {
        return rec['company'] as Map<String, dynamic>;
      }
      return rec;
    }
    return null;
  }

  String get companyName {
    final company = companyInfo;
    if (company != null) {
      return company['name']?.toString() ?? recruiterName;
    }
    return recruiterName;
  }

  String get companyDescription {
    final company = companyInfo;
    if (company != null) {
      return company['description']?.toString() ?? 'No description available';
    }
    return 'No description available';
  }

  String? get companyWebsite {
    final company = companyInfo;
    return company?['website']?.toString();
  }

  Map<String, dynamic>? get companyLocation {
    final company = companyInfo;
    if (company != null && company['location'] is Map) {
      return company['location'] as Map<String, dynamic>;
    }
    return null;
  }

  String get companyLocationString {
    final location = companyLocation;
    if (location != null) {
      final parts = <String>[];
      if (location['city'] != null) parts.add(location['city'].toString());
      if (location['state'] != null) parts.add(location['state'].toString());
      if (location['country'] != null)
        parts.add(location['country'].toString());
      return parts.join(', ');
    }
    return 'Location not specified';
  }

  String? get companyType {
    final company = companyInfo;
    return company?['companyType']?.toString();
  }

  int? get companyFoundedYear {
    final company = companyInfo;
    if (company?['founded'] != null) {
      if (company!['founded'] is int) return company['founded'];
      return int.tryParse(company['founded'].toString());
    }
    return null;
  }

  String? get companyLogo {
    final company = companyInfo;
    final logo = company?['logo']?.toString();
    return (logo != null && logo.isNotEmpty) ? logo : null;
  }
}

class JobPreferences {
  final List<String> skills;
  final String location;
  final int minExperience;
  final String education;

  JobPreferences({
    required this.skills,
    required this.location,
    required this.minExperience,
    required this.education,
  });

  factory JobPreferences.fromJson(Map<String, dynamic> json) {
    List<String> extractedSkills = [];
    if (json['skills'] != null) {
      extractedSkills = (json['skills'] as List)
          .map(
            (skill) =>
                skill is Map ? skill['type'].toString() : skill.toString(),
          )
          .toList();
    }

    return JobPreferences(
      skills: extractedSkills,
      location: json['location'] ?? '',
      minExperience: (json['minExperience'] is int)
          ? json['minExperience']
          : int.tryParse(json['minExperience']?.toString() ?? '0') ?? 0,
      education: json['education'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills.map((s) => {'type': s}).toList(),
      'location': location,
      'minExperience': minExperience,
      'education': education,
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
  static const String baseUrl2 =
      'https://hyrup-730899264601.asia-south1.run.app';
  // final String baseUrl2 = "http://10.168.89.157:3000";

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
          Uri.parse('$baseUrl2/college/opportunities'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ),
        http.get(
          Uri.parse('$baseUrl2/recruiter/jobs'),
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
      print("⚠️ Exception occurred while fetching Jobs");
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
      final url = '$baseUrl2/student/jobs/$jobId/$jobType/apply';

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
      _errorMessage = "Error occurred when applying to job";
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
        Uri.parse('$baseUrl2/jobs'),
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
