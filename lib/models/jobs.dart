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
  final SalaryRange salaryRange;
  final Preferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.recruiter,
    required this.salaryRange,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recruiter: json['recruiter'] ?? '',
      salaryRange: SalaryRange.fromJson(json['salaryRange'] ?? {}),
      preferences: Preferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'recruiter': recruiter,
      'salaryRange': salaryRange.toJson(),
      'preferences': preferences.toJson(),
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
  static const String baseUrl = 'http://10.35.166.157:3000';

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch jobs
  Future<void> fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _jobs = jsonData.map((jobJson) => Job.fromJson(jobJson)).toList();
      } else {
        _errorMessage = 'Failed to load jobs (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error fetching jobs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Apply for a job// Apply for a job
  Future<void> applyJob(String jobId) async {
    print("🔄 Starting job application...");
    print("📋 Job ID: $jobId");

    try {
      // ✅ GET FIREBASE ID TOKEN
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

      final url = '$baseUrl/student/jobs/$jobId/apply';

      print("🌐 API URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // ✅ SEND FIREBASE TOKEN
        },
        body: jsonEncode({}), // ✅ EMPTY BODY - studentId comes from token
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Application submitted successfully");
        _errorMessage = null;
      } else {
        print("❌ Application failed with status: ${response.statusCode}");
        _errorMessage =
            "Failed to apply: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      _errorMessage = "Error applying to job: $e";
    }

    notifyListeners();
  }

  // Create a single job
  Future<void> createJob(Job job) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(job.toJson()),
      );

      if (response.statusCode == 201) {
        final newJob = Job.fromJson(json.decode(response.body));
        _jobs.add(newJob);
      } else {
        _errorMessage = 'Failed to create job: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error creating job: $e';
    }
    notifyListeners();
  }
}
