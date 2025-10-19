import 'package:equatable/equatable.dart';

import 'hackathon.dart';

class HackathonResponse extends Equatable {
  final List<Hackathon> hackathons;

  const HackathonResponse({required this.hackathons});

  @override
  List<Object?> get props => [hackathons];
}
