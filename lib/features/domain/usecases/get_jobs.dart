import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';
import 'package:internappflutter/features/core/usecases/usecase.dart';
import 'package:internappflutter/features/domain/entities/job_response.dart';
import 'package:internappflutter/features/domain/repositories/job_repositories.dart';

/// Use case for fetching jobs.
class GetJobs implements UseCase<JobResponse, GetJobsParams> {
  final JobRepository repository;

  GetJobs(this.repository);

  @override
  Future<Either<Failure, JobResponse>> call(GetJobsParams params) async {
    return await repository.getJobs(
      page: params.page,
      limit: params.limit,
      query: params.query,
      location: params.location,
      skills: params.skills,
    );
  }
}

/// Parameters required for the GetJobs use case.
class GetJobsParams extends Equatable {
  final int page;
  final int limit;
  final String? query;
  final String? location;
  final String? skills;

  const GetJobsParams({
    required this.page,
    this.limit = 20,
    this.query,
    this.location,
    this.skills,
  });

  @override
  List<Object?> get props => [page, limit, query, location, skills];
}
