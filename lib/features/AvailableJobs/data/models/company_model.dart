import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.name,
    super.logo,
    super.companyType,
    super.description,
    super.industry,
    super.website,
    super.size,
  }) : super();

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    name: json["name"] as String? ?? 'N/A',
    logo: json["logo"] as String?,
    companyType: json["companyType"] as String?,

    // New fields
    description: json["description"] as String?,
    industry: json["industry"] as String?,
    website: json["website"] as String?,
    size: json["size"] as String?,
  );
}
