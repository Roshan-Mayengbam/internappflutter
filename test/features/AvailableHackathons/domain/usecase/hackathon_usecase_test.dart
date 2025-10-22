import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:internappflutter/features/AvailableHackathons/domain/entities/hackathon_response.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/repository/hackathon_repository.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/usecases/get_hackathons.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';

import 'hackathon_usecase_test.mocks.dart'; // Generated mock file

// We need to mock the repository which is a dependency of the use case.
@GenerateMocks([HackathonRepository])
void main() {
  // 1. Setup the necessary objects
  late GetHackathons usecase;
  late MockHackathonRepository mockHackathonRepository;

  // Dummy data for testing success scenario
  const tHackathonResponse = HackathonResponse(hackathons: []);
  // Dummy data for testing failure scenario
  const tServerFailure = ServerFailure('Test Server Failure');

  setUp(() {
    // Initialize the mock and the use case before each test
    mockHackathonRepository = MockHackathonRepository();
    usecase = GetHackathons(repository: mockHackathonRepository);
  });

  group('GetHackathons UseCase', () {
    test(
      'should call getHackathons() on the Repository and return HackathonResponse when successful',
      () async {
        // ARRANGE
        // When the mock repository's method is called, return a successful result (Right)
        when(
          mockHackathonRepository.getHackathons(),
        ).thenAnswer((_) async => const Right(tHackathonResponse));

        // ACT
        // Call the use case with 'null' as the parameter (void)
        final result = await usecase(null);

        // ASSERT
        // Verify that the repository method was called exactly once
        verify(mockHackathonRepository.getHackathons());
        // Check that the result matches the expected success value (Right<HackathonResponse>)
        expect(result, equals(const Right(tHackathonResponse)));
        // Ensure no more interactions with the mock repository
        verifyNoMoreInteractions(mockHackathonRepository);
      },
    );

    test(
      'should call getHackathons() on the Repository and return Failure when unsuccessful',
      () async {
        // ARRANGE
        // When the mock repository's method is called, return a failure result (Left)
        when(
          mockHackathonRepository.getHackathons(),
        ).thenAnswer((_) async => const Left(tServerFailure));

        // ACT
        final result = await usecase(null);

        // ASSERT
        // Verify that the repository method was called exactly once
        verify(mockHackathonRepository.getHackathons());
        // Check that the result matches the expected failure value (Left<Failure>)
        expect(result, equals(const Left(tServerFailure)));
        // Ensure no more interactions with the mock repository
        verifyNoMoreInteractions(mockHackathonRepository);
      },
    );
  });
}
