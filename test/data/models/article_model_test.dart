// test/data/models/article_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:internappflutter/features/data/models/article_model.dart';
import 'package:internappflutter/features/domain/entities/article.dart';

void main() {
  // --- Setup Mock JSON Data ---

  // Mock data representing a complete, valid API response result
  final Map<String, dynamic> tArticleJsonComplete = {
    "id": "world/2025/oct/07/test-article-1",
    "type": "article",
    "sectionId": "world",
    "sectionName": "World news",
    "webPublicationDate": "2025-10-07T10:00:00Z",
    "webTitle": "Test Article with All Fields Present",
    "webUrl": "https://www.theguardian.com/test/url",
    "apiUrl": "https://content.guardianapis.com/test/api",
    "isHosted": false,
    "fields": {
      "trailText": "<p>A short preview snippet.</p>",
      "thumbnail": "https://media.guim.co.uk/test-thumb.jpg",
      "byline": "Jane Doe",
      "body": "<h1>Full Article HTML Content.</h1><p>This is the body.</p>",
    },
  };

  // Mock data with missing/null fields to test robustness
  final Map<String, dynamic> tArticleJsonMissing = {
    "id": "world/2025/oct/07/test-article-2",
    "webTitle": "Test Article with Missing Fields",
    // sectionName, webPublicationDate, webUrl, apiUrl are present
    "fields": {
      "trailText": null, // Test null trailText
      "thumbnail": null, // Test null thumbnail
      // byline and body are entirely missing from 'fields'
    },
    // webPublicationDate is missing in this simplified example, but covered by dateString fallback
  };

  // --- Test Cases ---

  group('ArticleModel.fromJson', () {
    // 1) we are able to parse all attributes of the model correctly
    test('should correctly parse all fields from a complete JSON map', () {
      // Act
      final model = ArticleModel.fromJson(tArticleJsonComplete);

      // Assert
      expect(model, isA<ArticleModel>());
      expect(model.webTitle, 'Test Article with All Fields Present');
      expect(model.sectionName, 'World news');
      expect(model.webPublicationDate.year, 2025);
      expect(model.thumbnailUrl, 'https://media.guim.co.uk/test-thumb.jpg');
      expect(model.byline, 'Jane Doe');
      // trailText is cleaned (HTML tags removed)
      expect(model.trailText, 'A short preview snippet.');
      expect(model.bodyHtml, startsWith('<h1>Full Article HTML Content.</h1>'));
    });

    // 2) Handling whatever might be empty correctly
    test('should use default values for missing or null fields', () {
      // Act
      final model = ArticleModel.fromJson(tArticleJsonMissing);

      // Assert
      expect(model, isA<ArticleModel>());
      // Missing Thumbnail should default to empty string
      expect(model.thumbnailUrl, '');
      // Missing Byline should default to 'The Guardian Staff'
      expect(model.byline, 'The Guardian Staff');
      // Null trailText should default to the fallback text
      expect(model.trailText, 'Click to read full article.');
      // Missing body should default to the fallback content
      expect(model.bodyHtml, 'No article content available.');
      // Date should default to current time (harder to test precisely, but ensures no crash)
      expect(model.webPublicationDate, isA<DateTime>());
    });

    test(
      'should correctly convert ArticleModel (DTO) to Domain Article Entity',
      () {
        // Arrange
        final model = ArticleModel.fromJson(tArticleJsonComplete);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<Article>());
        // Check data integrity after conversion
        expect(entity.webTitle, model.webTitle);
        expect(entity.bodyHtml, model.bodyHtml);
      },
    );
  });
}
