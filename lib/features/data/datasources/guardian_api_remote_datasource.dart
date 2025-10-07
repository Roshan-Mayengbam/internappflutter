// lib/data/datasources/guardian_api_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internappflutter/core/constants/app_constants.dart';

/// Handles direct communication with the Guardian Content API.
class GuardianApiDataSource {
  static const String _baseUrl = "https://content.guardianapis.com/search";
  // NOTE: Replace 'YOUR_API_KEY_HERE' with your actual key before running.
  static const String _apiKey = AppConstants.guardianApiKey;
  static const int pageSize = 30; // Max items per request

  // Comprehensive, hardcoded list of tags for "tech news"
  static const List<String> _techTags = [
    "technology/technology",
    "technology/tech",
    "technology/innovation",
    "technology/gadgets",
    "technology/it",
    "technology/software",
    "technology/hardware",
    "technology/ai",
    "technology/robotics",
    "science/artificial-intelligence",
    "science/machine-learning",
    "science/deep-learning",
    "science/neural-networks",
    "technology/ai-tools",
    "technology/generative-ai",
    "technology/chatgpt",
    "technology/openai",
    "technology/programming",
    "technology/coding",
    "technology/developer",
    "technology/software-engineering",
    "technology/web-development",
    "technology/react",
    "technology/flutter",
    "technology/javascript",
    "technology/python",
    "technology/github",
    "business/tech-industry",
    "business/silicon-valley",
    "business/venture-capital",
    "business/tech-company",
    "business/startup-funding",
    "business/elon-musk",
    "technology/meta",
    "technology/amazon",
    "technology/microsoft",
  ];

  /// Joins the tech tags into a comma-separated string for the API query.
  static String get _techFilter => _techTags.join(',');

  /// Fetches raw JSON data (Map<String, dynamic>) from the Guardian API.
  Future<Map<String, dynamic>> fetchRawArticles(int page) async {
    // The 'show-fields' parameter is crucial for getting all required data
    const String fields = 'body,byline,thumbnail,trailText';

    final url = Uri.parse(
      '$_baseUrl?' +
          'api-key=$_apiKey&' +
          'show-fields=$fields&' +
          'tag=$_techFilter&' + // ENFORCING the comprehensive tech filter
          'page-size=$pageSize&' +
          'page=$page&' +
          'order-by=newest',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Handle API key errors, rate limiting, etc.
        print(
          'API Error: Status ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Failed to load articles: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network or parsing error: $e');
    }
  }
}
