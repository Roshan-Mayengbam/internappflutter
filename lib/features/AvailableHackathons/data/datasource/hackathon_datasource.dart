import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../models/hackathon_response_model.dart';
import '../../../core/errors/failiure.dart';

abstract class HackathonRemoteDataSource {
  Future<HackathonResponseModel> getHackathons();
}

class HackathonRemoteDataSourceImpl implements HackathonRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://hyrup-730899264601.asia-south1.run.app/student';
  final FirebaseAuth auth;

  HackathonRemoteDataSourceImpl({required this.client, required this.auth});

  @override
  Future<HackathonResponseModel> getHackathons() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw AuthFailure("No user is currently signed in.");
    }
    final idToken = await currentUser.getIdToken();

    final uri = Uri.parse('$baseUrl/hackathons');
    final response = await client.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      // Success: Decode the JSON and map it directly to the Data Model
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return HackathonResponseModel.fromJson(jsonMap);
    } else {
      // Failure: Throw an exception which will be caught in the RepositoryImpl
      throw ServerFailure(
        "Server Responded with Status Code : ${response.statusCode}",
      );
    }
  }
}
