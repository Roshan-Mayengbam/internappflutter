import 'package:dartz/dartz.dart';

import '../../../core/errors/failiure.dart';
import '../../domain/entities/job_response.dart';
import '../../domain/repositories/job_repositories.dart';
import '../datasources/job_response_remote_datasource.dart';
import '../models/job_response_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Optional: for checking network connection first

  JobRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, JobResponse>> getJobs({
    required int page,
    required int limit,
    String? query,
    String? location,
    String? skills,
  }) async {
    try {
      final remoteJobs = await remoteDataSource.getJobs(
        page: page,
        limit: limit,
        query: query,
        location: location,
        skills: skills,
      );
      return Right(remoteJobs.toEntity());
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkFailure {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
    // } else {
    //   return Left(NetworkFailure());
    // }
  }
}
