import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internappflutter/common/constants/app_constants.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';
import 'package:internappflutter/features/AvailableJobs/data/models/job_response_model.dart';

abstract class JobRemoteDataSource {
  Future<JobResponseModel> getJobs({
    required int page,
    required int limit,
    String? query,
    String? location,
    String? skills,
  });
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final http.Client client;
  final FirebaseAuth auth;
  final String _baseUrl = AppConstants.studentBaseUrl;

  JobRemoteDataSourceImpl({required this.client, required this.auth});

  @override
  Future<JobResponseModel> getJobs({
    required int page,
    required int limit,
    String? query,
    String? location,
    String? skills,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw AuthFailure("No user is currently signed in.");
    }
    final idToken = await currentUser.getIdToken();
    final Map<String, String> queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (query != null && query.isNotEmpty) {
      queryParameters['q'] = query;
    }
    if (location != null && location.isNotEmpty) {
      queryParameters['location'] = location;
    }
    if (skills != null && skills.isNotEmpty) {
      queryParameters['skills'] = skills;
    }

    final uri = Uri.parse(
      "$_baseUrl/jobs",
    ).replace(queryParameters: queryParameters);

    if (kDebugMode) print("$uri");

    try {
      final response = await client.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $idToken',
        },
      );

      debugPrint(
        '⬅️ REMOTE DATASOURCE: Received response. Status: ${response.statusCode} -\n ${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 3. Log the successful response body (or part of it)
        debugPrint(
          '✅ REMOTE DATASOURCE: Success! Data snippet: ${response.body.substring(0, 30)}...',
        );
        return JobResponseModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 500) {
        // 4. Log the full 500 error body for backend context
        debugPrint(
          '🚨 REMOTE DATASOURCE: Server Error 500 received! Full body: ${response.body}',
        );
        throw ServerFailure('Internal server error : ${response.statusCode}');
      } else {
        // 5. Log other client errors (400, 404, etc.)
        debugPrint(
          '⚠️ REMOTE DATASOURCE: Client Error ${response.statusCode}. Body: ${response.body}',
        );
        throw ServerFailure('Failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkFailure();
    }
  }
}
