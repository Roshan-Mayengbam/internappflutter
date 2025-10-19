import 'dart:convert';
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

  HackathonRemoteDataSourceImpl({required this.client});

  @override
  Future<HackathonResponseModel> getHackathons() async {
    final uri = Uri.parse('$baseUrl/hackathons');

    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
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
