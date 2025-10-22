import 'package:equatable/equatable.dart';

class Hackathon extends Equatable {
  final String id;
  final String title;
  final String organizer;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String? prizePool;
  final String? eligibility;
  final String? mode;
  final String? website;

  const Hackathon({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    this.prizePool,
    this.eligibility,
    this.website,
    this.mode,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    organizer,
    description,
    location,
    startDate,
    endDate,
    registrationDeadline,
    prizePool,
    eligibility,
    website,
    mode,
  ];
}
