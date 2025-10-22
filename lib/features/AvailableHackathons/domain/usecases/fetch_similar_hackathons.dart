// The Use Case takes the search query (a partial name) as a String
import 'package:dartz/dartz.dart';

import '../../../core/errors/failiure.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/hackathon_response.dart';
import '../repository/hackathon_repository.dart';

class GetSimilarHackathons extends UseCase<HackathonResponse, String> {
  final HackathonRepository repository;

  GetSimilarHackathons({required this.repository});

  @override
  Future<Either<Failure, HackathonResponse>> call(String? query) async {
    final normalizedQuery = query?.toLowerCase().trim();
    return await repository.getSimilarHackathons(normalizedQuery);
  }
}
