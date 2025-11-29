import 'package:hive/hive.dart';
import '../../domain/entities/article.dart';

abstract class NewsLocalDataSource {
  // Now requires a cacheKey to know which box to open
  Future<void> init(String cacheKey);

  // All retrieval/storage methods are now tied to the opened box
  List<Article> getCachedArticles();
  Future<void> cacheArticles(List<Article> articles);
  DateTime? getLastFetchTime();
  Future<void> saveLastFetchTime(DateTime time);

  // Optional: A method to close the box when done (good practice)
  Future<void> close();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  // Keys for the items inside the box remain constant
  static const String _articlesKey = 'articles';
  static const String _lastFetchTimeKey = 'last_fetch_time';

  // The box is no longer static; it holds the currently open box
  Box? _box;

  // 💡 Accepts the category/tag string to create a unique box name
  @override
  Future<void> init(String cacheKey) async {
    final boxName = 'news_cache_$cacheKey';

    if (_box?.name != boxName) {
      // Check if the correct box is already open
      if (_box != null && _box!.isOpen) {
        await _box!.close(); // Close any previously opened box
      }

      // 2. Open the unique box for this category
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox(boxName);
      } else {
        _box = Hive.box(boxName);
      }
    }
  }

  @override
  List<Article> getCachedArticles() {
    // Note: It's good practice to ensure _box is not null here in a real app
    final articles = _box?.get(_articlesKey);
    if (articles != null) {
      return (articles as List).cast<Article>();
    }
    return [];
  }

  @override
  Future<void> cacheArticles(List<Article> articles) async {
    await _box?.put(_articlesKey, articles);
  }

  @override
  DateTime? getLastFetchTime() {
    final timeString = _box?.get(_lastFetchTimeKey);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  @override
  Future<void> saveLastFetchTime(DateTime time) async {
    await _box?.put(_lastFetchTimeKey, time.toIso8601String());
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null; // Clear the reference
  }
}
