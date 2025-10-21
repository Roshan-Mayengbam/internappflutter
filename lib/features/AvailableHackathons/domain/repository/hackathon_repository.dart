import 'package:dartz/dartz.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/entities/hackathon_response.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';

abstract class HackathonRepository {
  Future<Either<Failure, HackathonResponse>> getHackathons();
  Future<Either<Failure, HackathonResponse>> getSimilarHackathons(
    String? query,
  );
}
