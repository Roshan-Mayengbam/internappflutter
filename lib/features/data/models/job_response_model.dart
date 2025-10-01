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
    required RecruiterModel recruiter,
    required String jobType,
    required SalaryRangeModel salaryRange,
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

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    recruiter: RecruiterModel.fromJson(json["recruiter"]),
    jobType: json["jobType"],
    salaryRange: SalaryRangeModel.fromJson(json["salaryRange"]),
    location: json["preferences"]["location"],
  );
}

class RecruiterModel extends Recruiter {
  const RecruiterModel({
    required String id,
    required String name,
    required CompanyModel company,
    required bool isVerified,
  }) : super(id: id, name: name, company: company, isVerified: isVerified);

  factory RecruiterModel.fromJson(Map<String, dynamic> json) => RecruiterModel(
    id: json["_id"],
    name: json["name"],
    company: CompanyModel.fromJson(json["companyId"]),
    isVerified: json["isVerified"] ?? false, // Parse new field
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
    id: json["_id"],
    name: json["name"],
    logo: json["logo"],
    companyType: json["companyType"], // Parse new field
  );
}

class SalaryRangeModel extends SalaryRange {
  const SalaryRangeModel({required int min, required int max})
    : super(min: min, max: max);

  factory SalaryRangeModel.fromJson(Map<String, dynamic> json) =>
      SalaryRangeModel(min: json["min"], max: json["max"]);
}
