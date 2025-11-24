// lib/data/datasources/guardian_api_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internappflutter/common/constants/app_constants.dart';

/// Handles direct communication with the Guardian Content API.
class GuardianApiDataSource {
  static const String _baseUrl = "https://content.guardianapis.com/search";
  static const String _apiKey = AppConstants.guardianApiKey;
  static const int pageSize = 30; // Max items per request

  /// Fetches raw JSON data (Map<String, dynamic>) from the Guardian API.
  Future<Map<String, dynamic>> fetchRawArticles(int page, String tags) async {
    // The 'show-fields' parameter is crucial for getting all required data
    const String fields = 'body,byline,thumbnail,trailText';

    final url = Uri.parse(
      '$_baseUrl?'
      'api-key=$_apiKey&'
      'show-fields=$fields&'
      'q=${Uri.encodeQueryComponent(tags)}&'
      'page-size=$pageSize&'
      'page=$page&'
      'order-by=newest',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Handle API key errors, rate limiting, etc.
      print('API Error: Status ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load articles: Status ${response.statusCode}');
    }
  }
}
