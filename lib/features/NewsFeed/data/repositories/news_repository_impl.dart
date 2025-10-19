import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/guardian_api_remote_datasource.dart';
import '../models/article_model.dart';

/// Concrete implementation of the NewsRepository interface defined in the Domain layer.
/// This implementation fetches data via the GuardianApiDataSource, maps the raw
/// API response using ArticleModel (the DTO), and converts it to the pure
/// Domain's Article entity.
class NewsRepositoryImpl implements NewsRepository {
  final GuardianApiDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Article>> fetchArticles(int page, String tags) async {
    final jsonResponse = await remoteDataSource.fetchRawArticles(page, tags);

    // --- FIX: Safely access nested JSON keys using '?[]' ---
    // We safely access 'response' and then 'results'.
    // If either is null, 'resultsList' will be null.
    final resultsList = jsonResponse['response']?['results'] as List<dynamic>?;

    // If the list is null, return an empty list immediately.
    final List<dynamic> results = resultsList ?? [];

    if (results.isEmpty) {
      // Return an empty list if no results were found, preventing further crashes.
      return [];
    }
    // --------------------------------------------------------

    // Assuming ArticleModel.fromJson and toEntity are robust (which they look to be)
    final List<ArticleModel> articleModels = results
        .map((json) => ArticleModel.fromJson(json))
        .toList();

    return articleModels.map((model) => model.toEntity()).toList();
  }
}
