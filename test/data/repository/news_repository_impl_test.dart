// test/data/repositories/news_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:internappflutter/features/data/repositories/news_repository_impl.dart';
import 'package:internappflutter/features/domain/entities/article.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.mocks.dart';

void main() {
  // --- Setup ---
  late NewsRepositoryImpl repository;
  late MockGuardianApiDataSource mockRemoteDataSource;

  setUp(() {
    // Initialize the mock and the repository using the mock
    mockRemoteDataSource = MockGuardianApiDataSource();
    repository = NewsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  // Sample data structure returned by the API (minimal for testing flow)
  final tApiJsonResponse = {
    "response": {
      "status": "ok",
      "userTier": "developer",
      "total": 60,
      "startIndex": 1,
      "pageSize": 30,
      "currentPage": 1,
      "pages": 2,
      "results": [
        // A minimal result that can be parsed by ArticleModel.fromJson
        {
          "id": "test/1",
          "webTitle": "Page 1 Result 1",
          "sectionName": "Test",
          "webPublicationDate": "2025-01-01T00:00:00Z",
          "webUrl": "url/1",
          "apiUrl": "api/1",
          "fields": {"trailText": "T1", "body": "B1"},
        },
      ],
    },
  };

  // --- Test Cases ---

  group('NewsRepositoryImpl', () {
    // 1) we are able to parse all attributes of the model correctly
    test(
      'should return a list of Domain Article entities when the call is successful',
      () async {
        // Arrange
        // Tell the mock to return our successful JSON map
        when(
          mockRemoteDataSource.fetchRawArticles(any),
        ).thenAnswer((_) async => tApiJsonResponse);

        // Act
        final result = await repository.fetchArticles(1);

        // Assert
        // Verify that the result is the expected Domain Entity
        expect(result, isA<List<Article>>());
        expect(result.length, 1);
        expect(result.first.webTitle, 'Page 1 Result 1');
      },
    );

    // 3) pagination is working perfectly fine
    test(
      'should call the data source with the correct page number for pagination',
      () async {
        // Arrange
        const tPage = 5; // We want to test page 5

        // Tell the mock to return a valid response for any page number
        when(
          mockRemoteDataSource.fetchRawArticles(any),
        ).thenAnswer((_) async => tApiJsonResponse);

        // Act
        await repository.fetchArticles(tPage);

        // Assert
        // Verify that fetchRawArticles was called exactly once with the requested page number
        verify(mockRemoteDataSource.fetchRawArticles(tPage)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should throw a generic Exception when the data source call fails',
      () async {
        // Arrange
        // Tell the mock to throw an exception
        when(
          mockRemoteDataSource.fetchRawArticles(any),
        ).thenThrow(Exception('Network failure'));

        // Assert
        // Verify that the repository catches the specific error and re-throws a generic one
        expect(() => repository.fetchArticles(1), throwsA(isA<Exception>()));
      },
    );
  });
}
