// lib/domain/usecases/get_tech_news_usecase.dart (UPDATED)

import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTechNewsUseCase {
  final NewsRepository repository;

  GetTechNewsUseCase(this.repository);

  /// Executes the common task: fetches articles for the given page and tags.
  Future<List<Article>> execute({
    required int page,
    required String tags,
  }) async {
    // You MUST update NewsRepository.fetchArticles to accept 'tags' too!
    return await repository.fetchArticles(page, tags);
  }
}
