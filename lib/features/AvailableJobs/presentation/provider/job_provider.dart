import 'package:flutter/material.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/get_jobs.dart';
import '../../domain/entities/job_response.dart';
import 'package:flutter/foundation.dart';

enum JobState { initial, loading, loaded, loadingMore, error, empty }

class JProvider with ChangeNotifier {
  final GetJobs getJobs;
  JProvider({required this.getJobs});

  // --- STATE ---
  int _currentPage = 0;
  final int _limit = 20;
  String? _currentQuery;

  JobState _state = JobState.initial;
  List<Job> _jobs = [];
  String _errorMessage = '';
  int _totalJobs = 0;
  bool _hasMoreData = true;

  // --- Getters ---
  JobState get state => _state;
  List<Job> get jobs => List.unmodifiable(_jobs);
  String get errorMessage => _errorMessage;
  int get totalJobs => _totalJobs;
  bool get hasMoreData => _hasMoreData;
  String? get currentQuery => _currentQuery;

  Future<void> fetchJobs({
    String? searchString,
    bool isLoadMore = false,
  }) async {
    // ⭐️ LOGGING: Function Entry Point
    debugPrint(
      '➡️ JProvider.fetchJobs CALLED. isLoadMore: $isLoadMore, searchString: "$searchString"',
    );

    final bool isNewSearch =
        (searchString != null && searchString != _currentQuery);

    if (isLoadMore) {
      if (!_hasMoreData) return;
      _currentPage++;
      _state = JobState.loadingMore;
    } else if (isNewSearch) {
      _currentPage = 1;
      _currentQuery = searchString;
      _jobs = [];
      _hasMoreData = true;
      _state = JobState.loading;
    } else if (_currentPage == 0) {
      _currentPage = 1;
      _state = JobState.loading;
      _currentQuery = null;
    } else {
      // ⭐️ LOGGING: Function Exit Point (Early Exit)
      debugPrint(
        '🛑 JProvider.fetchJobs EXIT: No change needed (current page is $_currentPage).',
      );
      return;
    }

    // ⭐️ LOGGING: State Transition BEFORE API Call
    debugPrint(
      '🔄 JProvider STATE UPDATE: State set to ${_state.name}. Notifying listeners...',
    );

    notifyListeners();

    final params = GetJobsParams(
      page: _currentPage,
      limit: _limit,
      query: _currentQuery,
    );

    debugPrint(
      '🔎 JProvider API CALL: Page: $_currentPage, Query: "$_currentQuery"',
    );

    final result = await getJobs(params);

    result.fold(
      (failure) {
        // ⭐️ LOGGING: API FAILED
        debugPrint(
          '❌ JProvider FAILED: Error on page $_currentPage. Failure: $failure',
        );

        if (_state != JobState.loadingMore) {
          _errorMessage = failure.toString();
          _state = JobState.error;
        } else {
          _state = JobState.loaded;
        }
        // ⭐️ LOGGING: State Transition AFTER API Failure
        debugPrint(
          '🚫 JProvider STATE UPDATE: Final state set to ${_state.name}. Notifying listeners...',
        );
        notifyListeners();
      },
      (response) {
        final JobResponse jobResponse = response;

        // ⭐️ LOGGING: API SUCCEEDED
        debugPrint(
          '✅ JProvider SUCCESS: Received ${jobResponse.total} total jobs. Current page: $_currentPage',
        );

        // a. Append or replace jobs
        if (isLoadMore) {
          _jobs.addAll(jobResponse.jobs);
        } else {
          _jobs = jobResponse.jobs;
        }

        // b. Update pagination status
        _totalJobs = jobResponse.total;
        final totalPages = (_totalJobs / _limit).ceil();
        _hasMoreData = (_currentPage < totalPages);

        // c. Set final state
        if (_jobs.isEmpty && !isLoadMore) {
          _state = JobState.empty;
        } else {
          _state = JobState.loaded;
        }

        // ⭐️ LOGGING: State Transition AFTER API Success
        debugPrint(
          '🎉 JProvider STATE UPDATE: Final state set to ${_state.name}. Total jobs in list: ${_jobs.length}. Notifying listeners...',
        );
        notifyListeners();
      },
    );
  }
}
