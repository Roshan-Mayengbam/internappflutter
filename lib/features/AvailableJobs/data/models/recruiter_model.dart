import '../../domain/entities/recruiter.dart';
import 'company_model.dart';

class RecruiterModel extends Recruiter {
  const RecruiterModel({
    required super.id,
    required super.firebaseId, // New
    required super.name,
    required super.designation, // New
    required CompanyModel super.company,
    required super.isVerified,
  });

  factory RecruiterModel.fromJson(Map<String, dynamic> json) {
    // Helper function for safer parsing of a nested object
    CompanyModel parseCompany(dynamic data) {
      if (data != null && data is Map<String, dynamic>) {
        return CompanyModel.fromJson(data);
      }
      return const CompanyModel(name: 'N/A');
    }

    return RecruiterModel(
      id: json["_id"] as String? ?? '',
      firebaseId: json["firebaseId"] as String? ?? '', // New
      name: json["name"] as String? ?? 'N/A',
      designation: json["designation"] as String? ?? 'N/A', // New
      // Company is EMBEDDED under the key 'company' in the schema
      company: parseCompany(json["company"]),

      // Backend key is 'isVerfied' (spelled this way in your schema)
      isVerified: json["isVerfied"] as bool? ?? false,
    );
  }
}
