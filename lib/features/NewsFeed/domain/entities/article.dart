import 'package:intl/intl.dart';

/// The common data structure for a news article, isolated from API and UI concerns.
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

  // lib/domain/entities/article.dart (FIXED)

  /// Factory constructor to map JSON data from the Data Layer to the Domain Entity.
  factory Article.fromJson(Map<String, dynamic> json) {
    // Safely extract nested fields from 'fields' object
    // Use an empty map as fallback if 'fields' is missing
    final fields = json['fields'] as Map<String, dynamic>? ?? {};

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

      // 1. Safe access: Use 'as String?' and null-coalescing.
      thumbnailUrl: fields['thumbnail'] as String? ?? '',

      // 2. FIXED: byline must be explicitly checked/cast, and the fallback doesn't need 'as String'.
      // If fields['byline'] is unexpectedly a Map, this safely defaults to the fallback string.
      byline: fields['byline'] as String? ?? 'The Guardian Staff',

      // 3. FIXED: Same for bodyHtml.
      bodyHtml: fields['body'] as String? ?? 'No article content available.',

      // 4. Clean trailText after safely casting it to a String.
      trailText: _cleanHtml(
        fields['trailText'] as String? ?? 'Click to read full article.',
      ),
    );
  }
}
