import 'package:flutter/material.dart';

import '../../../../common/constants/explore_page/explore_page_constant.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_tech_news.dart';

// Assuming ExploreFilter is defined elsewhere, e.g., in constants.

class ExploreViewModel extends ChangeNotifier {
  final GetTechNewsUseCase getNewsUseCase;

  ExploreViewModel({required this.getNewsUseCase});

  // --- State Variables ---
  bool _isLoading = false;
  List<Article> _articles = [];
  String? _errorMessage;
  int _currentPage = 1;
  ExploreFilter _selectedFilter = kVisibleExploreFilters.first;
  bool _initialLoadAttempted = false;

  // --- Caching Variables ---
  // Map: { FilterTag: { PageNumber: [List of Articles] } }
  final Map<ExploreFilter, Map<int, List<Article>>> _cache = {};

  // --- RATE LIMITING & DEBOUNCING PROPERTIES ---
  bool _isFetching = false;
  DateTime? _rateLimitUntil;
  final Duration _blockDuration = const Duration(seconds: 60);

  // --- Getters for UI access ---
  bool get isLoading => _isLoading;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;
  ExploreFilter get selectedFilter => _selectedFilter;
  bool get initialLoadAttempted => _initialLoadAttempted;
  bool get isRateLimited =>
      _rateLimitUntil != null && _rateLimitUntil!.isAfter(DateTime.now());

  // Helper for consistent logging
  void _log(String message) {
    debugPrint('[ExploreVM] $message');
  }

  // Helper to retrieve all articles for the current filter from the cache
  List<Article> _getCachedArticles(ExploreFilter filter) {
    if (!_cache.containsKey(filter)) {
      return [];
    }
    // Flatten all lists of articles across all pages for the current filter
    return _cache[filter]!.values.expand((list) => list).toList();
  }

  // --- Core Logic: Fetching News ---
  Future<void> fetchNews({bool isRefresh = false}) async {
    _log(
      '-> Initiating fetch. IsRefresh: $isRefresh, Current Page: $_currentPage, Filter: ${_selectedFilter.label}',
    );

    if (isRateLimited) {
      _errorMessage =
          'API is rate-limited. Please wait until ${_rateLimitUntil!.toLocal().toIso8601String()}.';
      notifyListeners();
      _log('Fetch ABORTED: Rate limit active.');
      return;
    }

    if (_isFetching && !isRefresh) {
      _log('Fetch ABORTED: A request is already in progress.');
      return;
    }

    // --- Prepare State ---
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    _initialLoadAttempted = true;

    if (isRefresh) {
      // When refreshing, we reset current state and check the cache for page 1 data.
      _currentPage = 1;
      _articles = _getCachedArticles(_selectedFilter);
      _log('State reset complete. Total cached articles: ${_articles.length}');

      // If we have cached data for page 1, we return it instantly and then fetch.
      if (_cache.containsKey(_selectedFilter) &&
          _cache[_selectedFilter]!.containsKey(1)) {
        // Only notify if we are showing cached data instantly
        notifyListeners();
      }
    }

    // Check cache for the *specific* page we are requesting
    if (_cache.containsKey(_selectedFilter) &&
        _cache[_selectedFilter]!.containsKey(_currentPage)) {
      final cachedPageArticles = _cache[_selectedFilter]![_currentPage]!;
      _articles = [..._articles, ...cachedPageArticles];
      _currentPage++;
      _isLoading = false;
      _isFetching = false;
      notifyListeners();
      _log('Fetch COMPLETE from CACHE for page $_currentPage.');
      return;
    }

    // If cache missed, proceed with API call.
    notifyListeners();

    _log(
      'Executing UseCase with tags: ${_selectedFilter.searchFilter}, page: $_currentPage',
    );

    try {
      // 3. Execute Use Case
      final newArticles = await getNewsUseCase.execute(
        page: _currentPage,
        tags: _selectedFilter.searchFilter,
      );

      _log('SUCCESS: Received ${newArticles.length} articles.');

      // 4. Update State on Success
      _articles = [..._articles, ...newArticles];
      _currentPage++;

      // --- CACHING STEP ---
      // Store the new page of articles in the cache map
      _cache.putIfAbsent(_selectedFilter, () => {});
      _cache[_selectedFilter]![_currentPage - 1] =
          newArticles; // Store by the page that was just fetched (currentPage - 1)
      _log(
        'Cache updated for Filter: ${_selectedFilter.label}, Page: ${_currentPage - 1}',
      );
    } on Exception catch (e, stack) {
      final errorString = e.toString();

      if (errorString.contains('Status 429') ||
          errorString.contains('Too Many Requests')) {
        _rateLimitUntil = DateTime.now().add(_blockDuration);
        _errorMessage =
            'Rate limit hit! Blocking requests for ${_blockDuration.inSeconds} seconds.';
        _log('ERROR: Rate Limit Triggered. Blocking until $_rateLimitUntil');
      } else {
        _errorMessage = 'Fetch FAILED for ${_selectedFilter.label}.';
        _log('ERROR: $_errorMessage\nException: $e\nStackTrace: $stack');
      }

      if (_articles.isEmpty) _articles = [];
    } finally {
      // 7. Finalize State
      _isLoading = false;
      _isFetching = false;
      _log(
        '<- Fetch finished. Total articles: ${_articles.length}, IsLoading: false.',
      );
      notifyListeners();
    }
  }

  // --- UI Action: Changing Filter ---
  void setFilter(ExploreFilter filter) {
    if (isRateLimited) {
      _log('Filter change ABORTED: Rate limit active.');
      return;
    }

    if (filter != _selectedFilter) {
      _log(
        'Filter change detected: ${_selectedFilter.label} -> ${filter.label}',
      );
      _selectedFilter = filter;

      // Check if we have any data cached for the new filter
      final cachedArticles = _getCachedArticles(_selectedFilter);
      if (cachedArticles.isNotEmpty) {
        _log('Filter change: Found cached data. Displaying now.');

        // Load cached state instantly
        _articles = cachedArticles;

        // Find the last page loaded in cache for this filter
        _currentPage =
            _cache[_selectedFilter]!.keys.reduce((a, b) => a > b ? a : b) + 1;

        // Reset error state and stop loading instantly
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } else {
        // If no cache, trigger a fresh API fetch
        fetchNews(isRefresh: true);
      }
    }
  }

  // --- UI Action: Loading More ---
  void loadMore() {
    // Guards ensure loadMore only triggers if not loading, not rate-limited, and not already fetching.
    if (!_isLoading && !isRateLimited && !_isFetching) {
      _log('LoadMore triggered.');
      fetchNews(isRefresh: false);
    }
  }
}
