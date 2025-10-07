import '../entities/article.dart';
import '../repositories/news_repository.dart';

/// Usecase (Interactor) to encapsulate the business logic of fetching
/// the next page of tech news.
///
/// It depends only on the domain repository interface.
class GetTechNewsUseCase {
  final NewsRepository repository;

  GetTechNewsUseCase(this.repository);

  /// Executes the core task: fetches articles for the given page number.
  ///
  /// The Provider will call this method, and it doesn't need to know
  /// whether the data comes from a network, database, or cache.
  Future<List<Article>> execute(int page) async {
    return await repository.fetchArticles(page);
  }
}
