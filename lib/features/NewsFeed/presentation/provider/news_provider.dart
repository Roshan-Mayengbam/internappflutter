import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/network/network_service.dart';

import '../../../../common/constants/explore_page/explore_page_constant.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_tech_news.dart';

class ExploreViewModel extends ChangeNotifier {
  final GetTechNewsUseCase getNewsUseCase;
  final NetworkService networkService;

  ExploreViewModel({
    required this.getNewsUseCase,
    required this.networkService,
  });

  // --- State Variables ---
  bool _isLoading = false;
  List<Article> _articles = [];
  String? _errorMessage;
  int _currentPage = 1;
  ExploreFilter _selectedFilter = kVisibleExploreFilters.first;
  bool _initialLoadAttempted = false;

  // --- Caching Variables ---
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

  void _log(String message) {
    debugPrint('[ExploreVM] $message');
  }

  List<Article> _getCachedArticles(ExploreFilter filter) {
    if (!_cache.containsKey(filter)) {
      return [];
    }
    return _cache[filter]!.values.expand((list) => list).toList();
  }

  // --- Core Logic: Fetching News (Network check removed) ---
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

    // ❌ REMOVED: NETWORK CONNECTIVITY CHECK - Now handled by StreamBuilder/Try-Catch

    // --- Prepare State ---
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    _initialLoadAttempted = true;

    if (isRefresh) {
      _currentPage = 1;
      _articles = _getCachedArticles(_selectedFilter);
      _log('State reset complete. Total cached articles: ${_articles.length}');

      if (_cache.containsKey(_selectedFilter) &&
          _cache[_selectedFilter]!.containsKey(1)) {
        notifyListeners();
      }
    }

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

    notifyListeners();

    _log(
      'Executing UseCase with tags: ${_selectedFilter.searchFilter}, page: $_currentPage',
    );

    try {
      final newArticles = await getNewsUseCase.execute(
        page: _currentPage,
        tags: _selectedFilter.searchFilter,
      );

      _log('SUCCESS: Received ${newArticles.length} articles.');

      _articles = [..._articles, ...newArticles];
      _currentPage++;

      _cache.putIfAbsent(_selectedFilter, () => {});
      _cache[_selectedFilter]![_currentPage - 1] = newArticles;
      _log(
        'Cache updated for Filter: ${_selectedFilter.label}, Page: ${_currentPage - 1}',
      );
    } on Exception catch (e, stack) {
      final errorString = e.toString();

      // Since the immediate network check is removed, we must rely on the network layer
      // throwing an exception for network failure and set the error message here.
      if (errorString.contains('SocketException') ||
          errorString.contains('Network')) {
        _errorMessage = 'Fetch FAILED: No network connection detected.';
        _log('ERROR: Network exception caught by fetchNews.');
      } else if (errorString.contains('Status 429') ||
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
      _isLoading = false;
      _isFetching = false;
      _log(
        '<- Fetch finished. Total articles: ${_articles.length}, IsLoading: false.',
      );
      notifyListeners();
    }
  }

  // --- UI Action: Changing Filter (Network check removed) ---
  void setFilter(ExploreFilter filter) async {
    if (isRateLimited) {
      _log('Filter change ABORTED: Rate limit active.');
      return;
    }

    // ❌ REMOVED: Immediate Network Check - Now relying on fetchNews failure

    if (filter != _selectedFilter) {
      _log(
        'Filter change detected: ${_selectedFilter.label} -> ${filter.label}',
      );
      _selectedFilter = filter;
      _errorMessage = null;

      final cachedArticles = _getCachedArticles(_selectedFilter);
      if (cachedArticles.isNotEmpty) {
        _log('Filter change: Found cached data. Displaying now.');

        _articles = cachedArticles;
        _currentPage =
            _cache[_selectedFilter]!.keys.reduce((a, b) => a > b ? a : b) + 1;

        _isLoading = false;
        notifyListeners();
      } else {
        fetchNews(isRefresh: true);
      }
    }
  }

  // --- UI Action: Loading More (rest of the code remains the same) ---
  void loadMore() {
    if (!_isLoading && !isRateLimited && !_isFetching) {
      _log('LoadMore triggered.');
      fetchNews(isRefresh: false);
    }
  }
}
