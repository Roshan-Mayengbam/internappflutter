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
  Future<List<Article>> fetchArticles(int page) async {
    try {
      // 1. Fetch raw JSON data using the Data Source
      // We assume remoteDataSource.fetchRawArticles is implemented to return the raw JSON Map
      final jsonResponse = await remoteDataSource.fetchRawArticles(page);

      // 2. Extract the list of results from the API structure
      // Safely navigate the nested JSON structure: response -> results
      final List<dynamic> results = jsonResponse['response']['results'] ?? [];

      // 3. Map the raw JSON objects to ArticleModel (DTOs)
      final List<ArticleModel> articleModels = results
          .map((json) => ArticleModel.fromJson(json))
          .toList();

      // 4. Convert the ArticleModels (DTOs) to clean Domain Article Entities using toEntity()
      return articleModels.map((model) => model.toEntity()).toList();
    } on Exception catch (e) {
      // Re-throw a generic exception suitable for the Usecase/Presentation layers
      throw Exception(
        'Could not fetch articles due to a network or API issue.',
      );
    }
  }
}
