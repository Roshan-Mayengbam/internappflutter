// Assumed Imports
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

import '../../../core/errors/failiure.dart';
import '../../domain/entities/hackathon.dart';
import '../../domain/usecases/fetch_similar_hackathons.dart'; // Assumed type for success result

// Define the State enum
enum HackathonState { initial, loading, loaded, error, empty }

class HackathonProvider with ChangeNotifier {
  // 1. Dependency Injection for the Use Case
  final GetSimilarHackathons getSimilarHackathons;

  HackathonProvider({required this.getSimilarHackathons});

  // State Management Fields
  HackathonState _state = HackathonState.initial;
  List<Hackathon> _hackathons = [];
  String? _errorMessage;
  String? _currentQuery;

  // Public Getters
  HackathonState get state => _state;
  List<Hackathon> get hackathons => _hackathons;
  String? get errorMessage => _errorMessage;
  String? get currentQuery => _currentQuery;

  // 2. Public Method to Trigger Search
  Future<void> fetchHackathons({String? searchString}) async {
    // ⭐️ LOGGING: Function Entry Point
    debugPrint(
      '➡️ HackathonProvider.fetchHackathons CALLED. searchString: "$searchString"',
    );

    // If no search string is provided, handle it as a request for all/initial data
    final query = searchString ?? '';

    // Check for new search or initial load logic
    final bool isNewSearch = (query != _currentQuery);

    // Prevent searching if the query hasn't changed and we're already loaded
    if (!isNewSearch && _state == HackathonState.loaded) {
      debugPrint(
        '🛑 HackathonProvider.fetchHackathons EXIT: Query "$query" is unchanged and state is Loaded.',
      );
      return;
    }

    // State preparation for a new search/load
    if (isNewSearch || _state == HackathonState.initial) {
      _state = HackathonState.loading;
      _currentQuery = query;
      _errorMessage = null;
    } else {
      // Should not happen based on the above logic, but for safety:
      debugPrint(
        '🛑 HackathonProvider.fetchHackathons EXIT: Unknown state logic prevented call.',
      );
      return;
    }

    // ⭐️ LOGGING: State Transition BEFORE API Call
    debugPrint(
      '🔄 HackathonProvider STATE UPDATE: State set to ${_state.name}. Query set to "$_currentQuery". Notifying listeners...',
    );

    notifyListeners();

    // 3. Execute the Use Case
    debugPrint(
      '🔎 HackathonProvider USECASE CALL: Executing GetSimilarHackathons with query: "$query"',
    );
    String? searchQuery = (query == '') ? null : query;
    final result = await getSimilarHackathons(searchQuery);

    // 4. Handle the Result (Either Success or Failure)
    result.fold(
      // Left side: Failure (Error or Not Found)
      (failure) {
        // ⭐️ LOGGING: USECASE FAILED
        debugPrint('❌ HackathonProvider FAILED: Failure received: $failure');

        _hackathons = [];
        _errorMessage = _mapFailureToMessage(failure);
        _state = (failure is NotFoundFailure)
            ? HackathonState.empty
            : HackathonState.error;

        // ⭐️ LOGGING: State Transition AFTER API Failure
        debugPrint(
          '🚫 HackathonProvider STATE UPDATE: Final state set to ${_state.name}. Notifying listeners...',
        );
        notifyListeners();
      },
      // Right side: Success (HackathonResponse)
      (response) {
        final hackathonResponse = response;

        debugPrint(
          '✅ HackathonProvider SUCCESS: Received ${hackathonResponse.hackathons.length} hackathons.',
        );

        _hackathons = hackathonResponse.hackathons;
        if (_hackathons.isEmpty) {
          _state = HackathonState.empty;
        } else {
          _state = HackathonState.loaded;
        }
        _errorMessage = null;

        // ⭐️ LOGGING: State Transition AFTER API Success
        debugPrint(
          '🎉 HackathonProvider STATE UPDATE: Final state set to ${_state.name}. Total hackathons in list: ${_hackathons.length}. Notifying listeners...',
        );
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error occurred. Please try again.';
    } else if (failure is NotFoundFailure) {
      return 'No results found.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
