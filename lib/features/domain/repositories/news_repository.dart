import '../entities/article.dart';

/// The contract defining how articles should be fetched.
/// This belongs to the Domain Layer and is an abstract interface.
/// The Data Layer is responsible for implementing this interface.
abstract class NewsRepository {
  /// Fetches a list of articles for a given page number.
  Future<List<Article>> fetchArticles(int page);
}
