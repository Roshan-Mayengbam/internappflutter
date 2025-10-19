import 'dart:convert';
import 'dart:io';
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

    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'q': query,
      if (location != null && location.isNotEmpty) 'location': location,
      if (skills != null && skills.isNotEmpty) 'skills': skills,
    };

    final uri = Uri.parse(
      "$_baseUrl/jobs",
    ).replace(queryParameters: queryParameters);

    try {
      final response = await client.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        return JobResponseModel.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw ServerFailure(errorBody['message'] ?? 'Failed to load jobs');
      }
    } on SocketException {
      throw NetworkFailure();
    }
  }
}
