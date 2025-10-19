import 'package:internappflutter/features/AvailableHackathons/domain/entities/hackathon_response.dart';

import 'hackathon_model.dart';

class HackathonResponseModel extends HackathonResponse {
  const HackathonResponseModel({required super.hackathons});

  factory HackathonResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? hackathonList = json['hackathons'] as List<dynamic>?;

    if (hackathonList == null) {
      return const HackathonResponseModel(hackathons: []);
    }
    final List<HackathonModel> parsedHackathons = hackathonList
        .map((item) {
          if (item is Map<String, dynamic>) {
            return HackathonModel.fromJson(item);
          }
          return null;
        })
        .whereType<
          HackathonModel
        >() // Filters out any null entries (malformed list items)
        .toList();
    return HackathonResponseModel(hackathons: parsedHackathons);
  }
}
