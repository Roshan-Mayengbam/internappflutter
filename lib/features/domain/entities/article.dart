import 'package:intl/intl.dart';

/// The core data structure for a news article, isolated from API and UI concerns.
class Article {
  final String id;
  final String webTitle;
  final String sectionName;
  final DateTime webPublicationDate;
  final String webUrl;
  final String apiUrl;
  final String thumbnailUrl;
  final String byline;
  final String bodyHtml;
  final String trailText;

  Article({
    required this.id,
    required this.webTitle,
    required this.sectionName,
    required this.webPublicationDate,
    required this.webUrl,
    required this.apiUrl,
    required this.thumbnailUrl,
    required this.byline,
    required this.bodyHtml,
    required this.trailText,
  });

  /// Helper to remove HTML tags and entities from snippet text
  static String _cleanHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }

  /// Factory constructor to map JSON data from the Data Layer to the Domain Entity.
  factory Article.fromJson(Map<String, dynamic> json) {
    // Safely extract nested fields from 'fields' object (where body, thumbnail, etc., reside)
    final fields = json['fields'] ?? {};

    final dateString =
        json['webPublicationDate'] ?? DateTime.now().toIso8601String();

    return Article(
      id: json['id'] as String,
      webTitle: json['webTitle'] as String,
      sectionName: json['sectionName'] as String,
      webPublicationDate: DateTime.tryParse(dateString) ?? DateTime.now(),
      webUrl: json['webUrl'] as String,
      apiUrl: json['apiUrl'] as String,

      // --- Fields extracted from the nested 'fields' object ---
      // Provide fallback values for required UI elements if the API is inconsistent
      thumbnailUrl: fields['thumbnail'] ?? '',
      byline: (fields['byline'] ?? 'The Guardian Staff') as String,
      bodyHtml: (fields['body'] ?? 'No article content available.') as String,
      // Clean the trailText (snippet) for clean display in the Explore list view
      trailText: _cleanHtml(
        (fields['trailText'] ?? 'Click to read full article.') as String,
      ),
    );
  }
}
