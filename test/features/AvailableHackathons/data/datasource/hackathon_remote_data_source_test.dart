import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart'; // Required for @GenerateMocks

// Import your system under test and dependencies
import 'package:internappflutter/features/AvailableHackathons/data/datasource/hackathon_datasource.dart';
import 'package:internappflutter/features/AvailableHackathons/data/models/hackathon_response_model.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';

// Import the generated mock file (will be created in Step 3)
import 'hackathon_remote_data_source_test.mocks.dart';

// 1. ANNOTATE: Tell Mockito to generate a mock for http.Client.
@GenerateMocks([http.Client])
void main() {
  // Use the generated class: MockClient
  late MockClient mockHttpClient;
  late HackathonRemoteDataSourceImpl dataSource;

  // Define constants for the expected request
  final String tBaseUrl =
      'https://hyrup-730899264601.asia-south1.run.app/student';
  final Uri tUri = Uri.parse('$tBaseUrl/hackathons');
  final Map<String, String> tHeaders = {'Content-Type': 'application/json'};

  // Mock JSON data for success (200)
  const tResponseJson = '''
  {
    "hackathons": [
      {
        "_id": "h1",
        "title": "Flutter Fest",
        "organizer": "Google",
        "description": "A dart hackathon",
        "location": "Online",
        "startDate": "2024-10-25T00:00:00.000Z",
        "endDate": "2024-10-27T00:00:00.000Z",
        "registrationDeadline": "2024-10-20T00:00:00.000Z"
      }
    ]
  }
  ''';
  // Define the expected model instance for comparison
  final tResponseModel = HackathonResponseModel.fromJson(
    json.decode(tResponseJson),
  );

  setUp(() {
    // Instantiate the generated mock class
    mockHttpClient = MockClient();
    dataSource = HackathonRemoteDataSourceImpl(
      client: mockHttpClient,
      auth: FirebaseAuth.instance,
    );
  });

  // --- Helper functions for stubbing the mock ---
  void setUpMockHttpClientSuccess200({String jsonBody = tResponseJson}) {
    // FIX: Use 'any' for the positional Uri argument. The generated mock handles
    // the Null Safety transition for this argument.
    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response(jsonBody, 200));
  }

  void setUpMockHttpClientFailure(int statusCode) {
    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response('Server Error', statusCode));
  }

  // --- TEST GROUP ---

  group('getHackathons', () {
    test(
      '[E] should perform a GET request to the exact URL and with the correct headers',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();

        // Act
        await dataSource.getHackathons();

        // Assert
        // Verification uses the exact values (tUri, tHeaders) for precision.
        verify(mockHttpClient.get(tUri, headers: tHeaders));
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should return HackathonResponseModel when the response code is 200',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();

        // Act
        final result = await dataSource.getHackathons();

        // Assert
        expect(result, tResponseModel);
      },
    );

    test(
      'should throw a ServerFailure when the response code is 404 (4xx error)',
      () async {
        // Arrange
        setUpMockHttpClientFailure(404);

        // Act
        final call = dataSource.getHackathons;

        // Assert
        expect(() => call(), throwsA(isA<ServerFailure>()));
      },
    );

    test(
      'should throw a ServerFailure when the response code is 500 (5xx error)',
      () async {
        // Arrange
        setUpMockHttpClientFailure(500);

        // Act
        final call = dataSource.getHackathons;

        // Assert
        expect(() => call(), throwsA(isA<ServerFailure>()));
      },
    );

    test(
      'should return an empty model when the response is 200 with empty data',
      () async {
        // Arrange
        const String emptyJson = '{"hackathons": []}';
        final HackathonResponseModel tEmptyModel = HackathonResponseModel(
          hackathons: [],
        );

        setUpMockHttpClientSuccess200(jsonBody: emptyJson);

        // Act
        final result = await dataSource.getHackathons();

        // Assert
        expect(result, tEmptyModel);
      },
    );
  });
}
