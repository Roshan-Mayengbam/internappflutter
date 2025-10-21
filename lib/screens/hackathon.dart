import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/models/hackathon.dart';
import 'dart:convert';
import 'hackathon.dart';

class HackathonProvider extends ChangeNotifier {
  List<Hackathon> _hackathons = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Hackathon> get hackathons => _hackathons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHackathons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        _errorMessage = "Could not get authentication token";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://hyrup-730899264601.asia-south1.run.app/student/hackathons',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      print('Hackathon API Response Status: ${response.statusCode}');
      print('Hackathon API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if hackathons key exists and is a list
        if (data['hackathons'] == null) {
          _errorMessage = 'No hackathons data received';
          _hackathons = [];
        } else {
          final List<dynamic> hackathonsList = data['hackathons'];

          // Parse each hackathon with error handling
          _hackathons = [];
          for (var hackathonJson in hackathonsList) {
            try {
              final hackathon = Hackathon.fromJson(hackathonJson);
              _hackathons.add(hackathon);
            } catch (e) {
              print('Error parsing hackathon: $e');
              print('Problematic JSON: $hackathonJson');
              // Continue parsing other hackathons
            }
          }

          _errorMessage = null;
          print('Successfully parsed ${_hackathons.length} hackathons');
        }
      } else {
        _errorMessage = 'Failed to load hackathons: ${response.statusCode}';
        print('Error response: ${response.body}');
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching hackathons: $e';
      print('Error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to retry fetching
  Future<void> retry() async {
    await fetchHackathons();
  }
}
