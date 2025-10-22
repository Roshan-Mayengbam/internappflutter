import 'package:dartz/dartz.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';
import '../entities/job_response.dart';

/// Abstract contract for the job data layer.
abstract class JobRepository {
  /// Fetches a paginated and filterable list of jobs.
  Future<Either<Failure, JobResponse>> getJobs({
    required int page,
    required int limit,
    String? query,
    String? location,
    String? skills,
  });
}
