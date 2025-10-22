import 'package:equatable/equatable.dart';
import 'company.dart'; // Ensure correct import path

class Recruiter extends Equatable {
  final String id;
  final String firebaseId;
  final String name;
  final String designation;
  final Company company;
  final bool isVerified;

  const Recruiter({
    required this.id,
    required this.firebaseId,
    required this.name,
    required this.designation,
    required this.company,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [
    id,
    firebaseId,
    name,
    designation,
    company,
    isVerified,
  ];
}
