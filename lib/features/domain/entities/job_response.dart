import 'package:equatable/equatable.dart';

class JobResponse extends Equatable {
  final List<Job> jobs;
  final int totalPages;
  final int currentPage;

  const JobResponse({
    required this.jobs,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [jobs, totalPages, currentPage];
}

class Job extends Equatable {
  final String id;
  final String title;
  final String description;
  final Recruiter recruiter;
  final String jobType;
  final SalaryRange salaryRange;
  final String? location;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.recruiter,
    required this.jobType,
    required this.salaryRange,
    this.location,
  });

  @override
  List<Object?> get props => [id, title, description, recruiter, jobType, salaryRange, location];
}

class Recruiter extends Equatable {
  final String id;
  final String name;
  final Company company;
  final bool isVerified; // Added this field

  const Recruiter({
    required this.id,
    required this.name,
    required this.company,
    required this.isVerified, // Added to constructor
  });

  @override
  List<Object?> get props => [id, name, company, isVerified]; // Added to props
}

class Company extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? companyType; // Added this field

  const Company({
    required this.id,
    required this.name,
    this.logo,
    this.companyType, // Added to constructor
  });

  @override
  List<Object?> get props => [id, name, logo, companyType]; // Added to props
}

class SalaryRange extends Equatable {
  final int min;
  final int max;

  const SalaryRange({
    required this.min,
    required this.max,
  });

  @override
  List<Object?> get props => [min, max];
}