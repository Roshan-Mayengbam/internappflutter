import 'package:equatable/equatable.dart';

class Preferences extends Equatable {
  final List<String> skills;
  final int? minExperience;
  final String? education;
  final String? location;

  const Preferences({
    this.skills = const [],
    this.minExperience,
    this.education,
    this.location,
  });

  @override
  List<Object?> get props => [skills, minExperience, education, location];
}
