import 'dart:convert';
import 'package:internappflutter/features/domain/entities/job_response.dart';

// The models from the previous response fit perfectly here.
// They act as Data Transfer Objects (DTOs) that handle JSON conversion
// and can be mapped to the domain entities.

// Helper function to decode a JSON string into a JobResponseModel
JobResponseModel jobResponseFromJson(String str) =>
    JobResponseModel.fromJson(json.decode(str));

// Main response object from the /jobs endpoint
class JobResponseModel extends JobResponse {
  const JobResponseModel({
    required List<JobModel> super.jobs,
    required super.totalPages,
    required super.currentPage,
  });

  factory JobResponseModel.fromJson(Map<String, dynamic> json) =>
      JobResponseModel(
        jobs: List<JobModel>.from(
          json["data"].map((x) => JobModel.fromJson(x)),
        ),
        totalPages: json["pagination"]["pages"],
        currentPage: json["pagination"]["page"],
      );
}

class JobModel extends Job {
  const JobModel({
    required String id,
    required String title,
    required String description,
    required Recruiter recruiter,
    required String jobType,
    required SalaryRange salaryRange,
    String? location,
  }) : super(
         id: id,
         title: title,
         description: description,
         recruiter: recruiter,
         jobType: jobType,
         salaryRange: salaryRange,
         location: location,
       );

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json["_id"] ?? '',
      title: json["title"] ?? 'No Title',
      description: json["description"] ?? '',
      // Safely parse nested recruiter object
      recruiter: json["recruiter"] != null
          ? RecruiterModel.fromJson(json["recruiter"])
          : const RecruiterModel(
              id: '',
              name: 'N/A',
              isVerified: false,
              company: CompanyModel(id: '', name: 'N/A'),
            ),
      jobType: json["jobType"] ?? 'N/A',
      // Safely parse nested salaryRange object
      salaryRange: json["salaryRange"] != null
          ? SalaryRangeModel.fromJson(json["salaryRange"])
          : const SalaryRangeModel(min: 0, max: 0),
      // Safely parse nested preferences object for location
      location:
          (json["preferences"] != null &&
              json["preferences"]["location"] != null)
          ? json["preferences"]["location"]
          : 'N/A',
    );
  }
}

class RecruiterModel extends Recruiter {
  const RecruiterModel({
    required String id,
    required String name,
    required CompanyModel company,
    required bool isVerified,
  }) : super(id: id, name: name, company: company, isVerified: isVerified);

  factory RecruiterModel.fromJson(Map<String, dynamic> json) => RecruiterModel(
    id: json["_id"] ?? '',
    name: json["name"] ?? 'N/A',
    // Safely parse nested companyId object
    company: json["companyId"] != null
        ? CompanyModel.fromJson(json["companyId"])
        : const CompanyModel(id: '', name: 'N/A'),
    isVerified: json["isVerified"] ?? false,
  );
}

class CompanyModel extends Company {
  const CompanyModel({
    required String id,
    required String name,
    String? logo,
    String? companyType,
  }) : super(id: id, name: name, logo: logo, companyType: companyType);

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    id: json["_id"] ?? '',
    name: json["name"] ?? 'N/A',
    logo: json["logo"],
    companyType: json["companyType"],
  );
}

class SalaryRangeModel extends SalaryRange {
  const SalaryRangeModel({required int min, required int max})
    : super(min: min, max: max);

  factory SalaryRangeModel.fromJson(Map<String, dynamic> json) =>
      SalaryRangeModel(min: json["min"] ?? 0, max: json["max"] ?? 0);
}
