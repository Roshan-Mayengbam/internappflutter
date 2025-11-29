import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/guardian_api_remote_datasource.dart';
import '../datasources/news_local_datasource.dart';
import '../models/article_model.dart';

/// Concrete implementation of the NewsRepository interface defined in the Domain layer.
/// This implementation fetches data via the GuardianApiDataSource, maps the raw
/// API response using ArticleModel (the DTO), and converts it to the pure
/// Domain's Article entity.
class NewsRepositoryImpl implements NewsRepository {
  final GuardianApiDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Article>> fetchArticles(int page, String tags) async {
    // 💡 FIX 1: Pass the 'tags' (category key) to initialize the specific cache box.
    // The 'localDataSource' will use this key to open the correct Hive box.
    await localDataSource.init(tags); // <--- CHANGE HERE

    final lastFetchTime = localDataSource.getLastFetchTime();
    final now = DateTime.now();
    final isCacheValid =
        lastFetchTime != null && now.difference(lastFetchTime).inMinutes < 30;

    // Return cached data if valid and requesting the first page
    if (page == 1 && isCacheValid) {
      final cachedArticles = localDataSource.getCachedArticles();
      if (cachedArticles.isNotEmpty) {
        // 💡 HINT: Add a log statement here for debugging cache hits
        print('Returning cached data for tags: $tags');
        return cachedArticles;
      }
    }

    // Fetch from remote
    final jsonResponse = await remoteDataSource.fetchRawArticles(page, tags);

    // --- Safe JSON access logic remains correct ---
    final resultsList = jsonResponse['response']?['results'] as List<dynamic>?;
    final List<dynamic> results = resultsList ?? [];

    if (results.isEmpty) {
      return [];
    }
    // ---------------------------------------------

    final List<ArticleModel> articleModels = results
        .map((json) => ArticleModel.fromJson(json))
        .toList();

    final newArticles = articleModels.map((model) => model.toEntity()).toList();

    // Merge and cache logic only executes if we fetched new data

    // 💡 Refinement: Only merge if fetching the first page (or if you want to
    // maintain a single, massive cache per category).
    if (page == 1) {
      // Merge new articles with the current category cache
      final currentCached = localDataSource.getCachedArticles();

      // Use a Map for deduplication by ID, prioritizing newer items (newArticles)
      final Map<String, Article> mergedMap = {
        for (var a in currentCached) a.id: a, // Existing cached
        for (var a in newArticles) a.id: a, // Overwrite with new if IDs match
      };

      final mergedList = mergedMap.values.toList();
      // Sort by publication date descending
      mergedList.sort(
        (a, b) => b.webPublicationDate.compareTo(a.webPublicationDate),
      );

      // Store the newly merged list back into the category-specific box
      await localDataSource.cacheArticles(mergedList);
      await localDataSource.saveLastFetchTime(now);

      // Return the full merged list
      return mergedList;
    }

    // If it's a subsequent page (page > 1), don't cache or merge, just return the new results.
    // This prevents page 2+ results from invalidating the page 1 cache time and bloating the list unnecessarily.
    return newArticles;
  }
}
