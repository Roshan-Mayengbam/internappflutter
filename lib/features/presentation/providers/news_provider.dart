import 'package:flutter/material.dart';

import '../../../core/constants/explore_page/explore_page_constant.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_tech_news.dart';

class ExploreViewModel extends ChangeNotifier {
  final GetTechNewsUseCase getNewsUseCase;

  ExploreViewModel({required this.getNewsUseCase});

  // --- State Variables ---
  bool _isLoading = false;
  List<Article> _articles = [];
  String? _errorMessage;
  int _currentPage = 1;
  ExploreFilter _selectedFilter = kVisibleExploreFilters.first;
  bool _initialLoadAttempted = false; // <-- CRITICAL GUARD FLAG

  // --- Getters for UI access ---
  bool get isLoading => _isLoading;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;
  ExploreFilter get selectedFilter => _selectedFilter;
  bool get initialLoadAttempted => _initialLoadAttempted;

  // Helper for consistent logging
  void _log(String message) {
    debugPrint('[ExploreVM] $message');
  }

  // --- Core Logic: Fetching News ---
  Future<void> fetchNews({bool isRefresh = false}) async {
    _log(
      '-> Initiating fetch. IsRefresh: $isRefresh, Current Page: $_currentPage, Filter: ${_selectedFilter.label}',
    );

    if (_isLoading && !isRefresh) {
      _log('Fetch ignored: already loading.');
      return;
    }

    // 1. Prepare State
    _isLoading = true;
    _errorMessage = null;

    if (isRefresh) {
      _articles = [];
      _currentPage = 1;
      _log('State reset complete. Current Page is now 1.');
    }

    notifyListeners();

    _log(
      'Executing UseCase with tags: ${_selectedFilter.searchFilter}, page: $_currentPage',
    );

    try {
      // 2. Execute Use Case
      final newArticles = await getNewsUseCase.execute(
        page: _currentPage,
        tags: _selectedFilter.searchFilter,
      );

      _log('SUCCESS: Received ${newArticles.length} articles.');

      // 3. Update State on Success
      _articles = [..._articles, ...newArticles];
      _currentPage++;
    } catch (e, stack) {
      // 4. Handle Error Safely
      _errorMessage = 'Fetch FAILED for ${_selectedFilter.label}.';
      _log('ERROR: $_errorMessage\nException: $e\nStackTrace: $stack');

      if (_articles.isEmpty) _articles = [];
    } finally {
      // 5. Finalize State
      _initialLoadAttempted = true; // <-- SET FLAG HERE
      _isLoading = false;
      _log(
        '<- Fetch finished. Total articles: ${_articles.length}, IsLoading: false. InitialLoadAttempted: true',
      );
      notifyListeners();
    }
  }

  // --- UI Action: Changing Filter ---
  void setFilter(ExploreFilter filter) {
    if (filter != _selectedFilter) {
      _log(
        'Filter change detected: ${_selectedFilter.label} -> ${filter.label}',
      );
      // Reset the attempted flag when changing filter to allow a new fetch
      _initialLoadAttempted = false;
      _selectedFilter = filter;
      fetchNews(isRefresh: true);
    }
  }

  // --- UI Action: Loading More ---
  void loadMore() {
    if (!_isLoading) {
      _log('LoadMore triggered.');
      fetchNews(isRefresh: false);
    }
  }
}
