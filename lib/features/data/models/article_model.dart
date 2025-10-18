import '../../domain/entities/article.dart';

class ArticleModel {
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

  ArticleModel({
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

  // Helper to remove HTML tags and entities from snippet text
  static String _cleanHtml(String? htmlString) {
    // If the input is null, provide the default text for the card snippet.
    String text = htmlString ?? 'Click to read full article.';
    text = text.length > 100
        ? "${text.substring(0, 100)}....\n\n\t\tSee more in the website"
        : text;
    // Basic regex to strip HTML tags and common entities for clean display
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }

  /// Factory constructor to map raw JSON data from the API response.
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] ?? {};
    final dateString =
        json['webPublicationDate'] ?? DateTime.now().toIso8601String();

    return ArticleModel(
      // Top-level fields
      id: (json['id'] as String?) ?? '', // Safely cast and provide fallback
      webTitle: (json['webTitle'] as String?) ?? 'Untitled Article',
      sectionName: (json['sectionName'] as String?) ?? 'News',
      webPublicationDate: DateTime.tryParse(dateString) ?? DateTime.now(),
      webUrl: (json['webUrl'] as String?) ?? '',
      apiUrl: (json['apiUrl'] as String?) ?? '',

      // Nested 'fields' object
      thumbnailUrl: (fields['thumbnail'] as String?) ?? '',
      byline: (fields['byline'] as String?) ?? 'The Guardian Staff',
      bodyHtml: _cleanHtml(
        fields['body'] as String? ?? 'No article content available.',
      ),

      // Clean the trailText, which now handles the fallback internally
      trailText: _cleanHtml(fields['body'] as String?),
    );
  }

  /// Converts the Data Model (DTO) into a clean Domain Entity.
  Article toEntity() {
    return Article(
      id: id,
      webTitle: webTitle,
      sectionName: sectionName,
      webPublicationDate: webPublicationDate,
      webUrl: webUrl,
      apiUrl: apiUrl,
      thumbnailUrl: thumbnailUrl,
      byline: byline,
      bodyHtml: bodyHtml,
      trailText: trailText,
    );
  }
}
