import '../../domain/entities/hackathon.dart';

class HackathonModel extends Hackathon {
  const HackathonModel({
    required super.id,
    required super.title,
    required super.organizer,
    required super.description,
    required super.location,
    required super.startDate,
    required super.endDate,
    required super.registrationDeadline,
    super.prizePool,
    super.eligibility,
    super.website,
    super.mode,
  });

  factory HackathonModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse a nullable date string
    DateTime? parseDate(dynamic dateString) {
      if (dateString is String) {
        // Use DateTime.tryParse for safety, or DateTime.parse if you are certain
        return DateTime.tryParse(dateString)?.toLocal();
      }
      return null;
    }

    return HackathonModel(
      // Required fields with fallback for safety
      id: json["_id"] as String? ?? '',
      title: json["title"] as String? ?? 'Untitled Hackathon',
      organizer: json["organizer"] as String? ?? 'Unknown Organizer',
      description: json["description"] as String? ?? 'No description provided.',
      location: json["location"] as String? ?? 'Online',

      startDate: parseDate(json["startDate"])!,
      endDate: parseDate(json["endDate"])!,
      registrationDeadline: parseDate(json["registrationDeadline"])!,

      // Optional fields
      prizePool: json["prizePool"] as String?,
      eligibility: json["eligibility"] as String?,
      website: json["website"] as String?,
      mode: json["mode"] as String?,
    );
  }
}
