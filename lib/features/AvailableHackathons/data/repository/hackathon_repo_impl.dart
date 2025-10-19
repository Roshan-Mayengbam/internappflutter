import 'package:dartz/dartz.dart';

import '../../../core/errors/failiure.dart';
import '../../domain/entities/hackathon_response.dart';
import '../../domain/repository/hackathon_repository.dart';
import '../datasource/hackathon_datasource.dart'; // Domain Entity for return type

class HackathonRepositoryImpl implements HackathonRepository {
  final HackathonRemoteDataSource remoteDataSource;
  // If you had a local DB, you'd inject LocalDataSource here too.

  HackathonRepositoryImpl({required this.remoteDataSource});

  @override
  // The return type is the Domain Entity wrapped in an Either
  Future<Either<Failure, HackathonResponse>> getHackathons() async {
    try {
      final remoteData = await remoteDataSource.getHackathons();

      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure("Server Responded with status code : $e"));
    }
  }
}
