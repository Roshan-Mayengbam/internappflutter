import 'package:flutter/material.dart';
import 'package:internappflutter/features/domain/usecases/get_jobs.dart';
import 'package:internappflutter/features/domain/entities/job_response.dart';

enum JobState { initial, loading, loaded, error }

class JProvider with ChangeNotifier {
  final GetJobs getJobs;
  JProvider({required this.getJobs});

  JobState _state = JobState.initial;
  JobState get state => _state;

  List<Job> _jobs = [];
  List<Job> get jobs => _jobs;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchJobs() async {
    _state = JobState.loading;
    notifyListeners();

    final result = await getJobs(const GetJobsParams(page: 1));

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _state = JobState.error;
        notifyListeners();
      },
      (jobResponse) {
        _jobs = jobResponse.jobs;
        _state = JobState.loaded;
        notifyListeners();
      },
    );
  }
}