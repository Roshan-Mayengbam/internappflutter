import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final String name;
  final String? logo;
  final String? companyType;

  // New fields you might want to expose
  final String? description;
  final String? industry;
  final String? website;
  final String? size;

  const Company({
    required this.name,
    this.logo,
    this.companyType,
    this.description,
    this.industry,
    this.website,
    this.size,
  });

  @override
  List<Object?> get props => [
    // id, // Removed
    name,
    logo,
    companyType,
    description,
    industry,
    website,
    size,
  ];
}
