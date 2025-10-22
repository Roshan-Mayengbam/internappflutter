import 'package:dartz/dartz.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/entities/hackathon_response.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/repository/hackathon_repository.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';
import 'package:internappflutter/features/core/usecases/usecase.dart';

class GetHackathons extends UseCase<HackathonResponse, void> {
  final HackathonRepository repository;
  GetHackathons({required this.repository});

  @override
  Future<Either<Failure, HackathonResponse>> call(void params) {
    return repository.getHackathons();
  }
}
