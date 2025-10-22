import 'dart:convert';

import '../../domain/entities/job_response.dart';
import 'job_model.dart';

// Helper function to decode a JSON string into a JobResponseModel
JobResponseModel jobResponseFromJson(String str) =>
    JobResponseModel.fromJson(json.decode(str));

// Main response object from the /jobs endpoint
class JobResponseModel {
  final List<JobModel> jobs;
  final int totalPages;
  final int currentPage;

  const JobResponseModel({
    required this.jobs,
    required this.totalPages,
    required this.currentPage,
  });

  factory JobResponseModel.fromJson(Map<String, dynamic> json) =>
      JobResponseModel(
        jobs: List<JobModel>.from(
          (json["data"] as List<dynamic>).map(
            (x) => JobModel.fromJson(x as Map<String, dynamic>),
          ),
        ),
        totalPages: json["pagination"]["pages"] as int,
        currentPage: json["pagination"]["page"] as int,
      );
}

extension JobResponseMapper on JobResponseModel {
  JobResponse toEntity() {
    return JobResponse(
      // The List of Models automatically maps to a List of Entities
      // because JobModel extends Job (Entity).
      jobs: jobs,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }
}
