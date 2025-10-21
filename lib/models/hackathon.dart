class Hackathon {
  final String id;
  final String title;
  final String organizer;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String? prizePool;
  final String eligibility;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hackathon({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    this.prizePool,
    required this.eligibility,
    this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hackathon.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates
    DateTime parseDate(dynamic dateValue, DateTime fallback) {
      if (dateValue == null) return fallback;
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is DateTime) {
          return dateValue;
        }
        return fallback;
      } catch (e) {
        print('Error parsing date: $dateValue, error: $e');
        return fallback;
      }
    }

    final now = DateTime.now();

    return Hackathon(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Hackathon',
      organizer: json['organizer']?.toString() ?? 'Unknown Organizer',
      description:
          json['description']?.toString() ?? 'No description available',
      location: json['location']?.toString() ?? 'Online',
      startDate: parseDate(json['startDate'], now),
      endDate: parseDate(json['endDate'], now.add(const Duration(days: 7))),
      registrationDeadline: parseDate(
        json['registrationDeadline'],
        now.add(const Duration(days: 3)),
      ),
      prizePool: json['prizePool']?.toString(),
      eligibility: json['eligibility']?.toString() ?? 'Open to all',
      website: json['website']?.toString(),
      createdAt: parseDate(json['createdAt'], now),
      updatedAt: parseDate(json['updatedAt'], now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'organizer': organizer,
      'description': description,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'prizePool': prizePool,
      'eligibility': eligibility,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
