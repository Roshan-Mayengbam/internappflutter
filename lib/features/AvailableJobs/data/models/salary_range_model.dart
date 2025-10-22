import '../../domain/entities/salary_range.dart';

class SalaryRangeModel extends SalaryRange {
  const SalaryRangeModel({required super.min, required super.max});

  factory SalaryRangeModel.fromJson(Map<String, dynamic> json) =>
      SalaryRangeModel(
        // Assuming min/max are always ints in the backend
        min: json["min"] as int? ?? 0,
        max: json["max"] as int? ?? 0,
      );
}
