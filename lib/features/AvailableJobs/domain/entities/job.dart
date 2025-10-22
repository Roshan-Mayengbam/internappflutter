import 'package:equatable/equatable.dart';
import 'recruiter.dart'; // Ensure correct import path
import 'salary_range.dart'; // Ensure correct import path
import 'preferences.dart'; // NEW: Import the Preferences class

class Job extends Equatable {
  final String id;
  final String title;
  final String description; // The original full description

  // New structured description fields (optional)
  final String? rolesAndResponsibilities;
  final String? perks;
  final String? details;

  final Recruiter recruiter;
  final String jobType; // enum: ["company", "on-campus", "external"]

  // New fields
  final String employmentType; // enum: ["full-time", "part-time", ...]
  final int noOfOpenings;
  final String? duration; // Optional
  final String mode; // enum: ["remote", "on-site", "hybrid"]
  final num? stipend; // Use num to handle both int and double if necessary

  // Existing fields
  final SalaryRange salaryRange;
  final String? college; // Conditional field
  final String? applicationLink; // Conditional field

  // INCORPORATED PREFERENCES FIELD
  final Preferences preferences;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    this.rolesAndResponsibilities,
    this.perks,
    this.details,
    required this.recruiter,
    required this.jobType,
    required this.employmentType,
    required this.noOfOpenings,
    this.duration,
    required this.mode,
    this.stipend,
    required this.salaryRange,
    this.college,
    this.applicationLink,
    // preferences is required and must be provided
    required this.preferences,
    // The previous standalone 'location' field is removed as it's now in Preferences
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    rolesAndResponsibilities,
    perks,
    details,
    recruiter,
    jobType,
    employmentType,
    noOfOpenings,
    duration,
    mode,
    stipend,
    salaryRange,
    college,
    applicationLink,
    // Add the new object to the props list
    preferences,
  ];
}
