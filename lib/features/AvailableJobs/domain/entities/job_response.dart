import 'package:equatable/equatable.dart';
import 'job.dart';

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
