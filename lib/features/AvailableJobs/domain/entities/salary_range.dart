import 'package:equatable/equatable.dart';

class SalaryRange extends Equatable {
  final int min;
  final int max;

  const SalaryRange({required this.min, required this.max});

  @override
  List<Object?> get props => [min, max];
}
