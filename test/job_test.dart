import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:internappflutter/features/AvailableJobs/data/models/job_response_model.dart';
import 'package:internappflutter/features/AvailableJobs/domain/entities/job_response.dart';

// A helper function to read fixture files (optional, but good practice)
// For this example, we'll embed the JSON directly.

void main() {
  // Sample JSON representing a successful response with two jobs
  final nonEmptyJsonResponse = json.decode('''
  {
    "data": [
      {
        "_id": "60d0fe4f5311236168a109ca",
        "title": "Senior Flutter Developer",
        "description": "Developing high-quality mobile applications.",
        "recruiter": {
          "_id": "60d0fe4f5311236168a109cb",
          "name": "Jane Doe",
          "companyId": {
            "_id": "60d0fe4f5311236168a109cc",
            "name": "Tech Solutions Inc.",
            "logo": "http://example.com/logo.png"
          }
        },
        "jobType": "company",
        "salaryRange": {
          "min": 80000,
          "max": 120000
        },
        "preferences": {
          "location": "Remote"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "pages": 1
    }
  }
  ''');

  // Sample JSON representing a successful response with zero jobs
  final emptyJsonResponse = json.decode('''
  {
    "data": [],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 0,
      "pages": 0
    }
  }
  ''');

  group('JobResponseModel', () {
    test('should be a subclass of JobResponse entity', () {
      // assert
      expect(
        JobResponseModel(jobs: [], totalPages: 1, currentPage: 1, total: 20),
        isA<JobResponse>(),
      );
    });

    test('should correctly parse a non-empty JSON response', () {
      // act
      final result = JobResponseModel.fromJson(nonEmptyJsonResponse);

      // assert
      expect(result, isA<JobResponseModel>());
      expect(result.jobs.length, 1);
      expect(result.currentPage, 1);
      expect(result.totalPages, 1);

      // Check the details of the parsed job
      final job = result.jobs.first;
      expect(job.id, '60d0fe4f5311236168a109ca');
      expect(job.title, 'Senior Flutter Developer');
      expect(job.preferences.location, 'Remote');
      expect(job.recruiter.name, 'Jane Doe');
      expect(job.recruiter.company.name, 'Tech Solutions Inc.');
      expect(job.salaryRange.min, 80000);
    });

    test('should correctly parse an empty JSON response', () {
      // act
      final result = JobResponseModel.fromJson(emptyJsonResponse);

      // assert
      expect(result, isA<JobResponseModel>());
      expect(result.jobs, isEmpty);
      expect(result.currentPage, 1);
      expect(result.totalPages, 0);
    });
  });
}
