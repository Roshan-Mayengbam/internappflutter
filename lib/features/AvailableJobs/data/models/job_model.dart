import '../../domain/entities/job.dart';

import 'recruiter_model.dart';
import 'company_model.dart';
import 'salary_range_model.dart';
import 'preference_model.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.description,
    super.rolesAndResponsibilities,
    super.perks,
    super.details,
    required super.recruiter,
    required super.jobType,
    required super.employmentType,
    required super.noOfOpenings,
    super.duration,
    required super.mode,
    super.stipend,
    required super.salaryRange,
    super.college,
    super.applicationLink,
    required super.preferences, // UPDATED: Use the Preferences object
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Helper function for safer parsing of a nested object
    RecruiterModel parseRecruiter(dynamic data) {
      if (data != null && data is Map<String, dynamic>) {
        return RecruiterModel.fromJson(data);
      }
      return const RecruiterModel(
        id: '',
        firebaseId: '',
        name: 'N/A',
        designation: 'N/A',
        isVerified: false,
        company: CompanyModel(name: 'N/A'),
      );
    }

    // Helper function for safer parsing of salary range
    SalaryRangeModel _parseSalaryRange(dynamic data) {
      if (data != null && data is Map<String, dynamic>) {
        return SalaryRangeModel.fromJson(data);
      }
      return const SalaryRangeModel(min: 0, max: 0);
    }

    // NEW: Helper function for safer parsing of preferences
    PreferencesModel _parsePreferences(dynamic data) {
      if (data != null && data is Map<String, dynamic>) {
        return PreferencesModel.fromJson(data);
      }
      // Return a default, empty Preferences object if data is missing
      return const PreferencesModel();
    }

    return JobModel(
      id: json["_id"] as String? ?? '',
      title: json["title"] as String? ?? 'No Title',
      description: json["description"] as String? ?? '',

      // New structured description fields
      rolesAndResponsibilities: json["rolesAndResponsibilities"] as String?,
      perks: json["perks"] as String?,
      details: json["details"] as String?,

      // Nested objects
      recruiter: parseRecruiter(json["recruiter"]),
      salaryRange: _parseSalaryRange(json["salaryRange"]),
      preferences: _parsePreferences(
        json["preferences"],
      ), // NEW: Parse preferences

      jobType: json["jobType"] as String? ?? 'N/A',

      // New fields
      employmentType: json["employmentType"] as String? ?? 'full-time',
      noOfOpenings: json["noOfOpenings"] as int? ?? 1,
      duration: json["duration"] as String?,
      mode: json["mode"] as String? ?? 'on-site',
      // Mongoose saves numbers as double or int, use num or cast to int if sure
      stipend: json["stipend"] as num?,

      // Conditional fields
      college: json["college"] as String?,
      applicationLink: json["applicationLink"] as String?,

      // The previous standalone location field is REMOVED
      // location: (json["preferences"] as Map<String, dynamic>?)?["location"] as String?,
    );
  }
}
