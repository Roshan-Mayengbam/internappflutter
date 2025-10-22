import '../../domain/entities/preferences.dart'; // Import the Preferences entity

class PreferencesModel extends Preferences {
  const PreferencesModel({
    super.skills = const [],
    super.minExperience,
    super.education,
    super.location,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      skills:
          (json["skills"] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minExperience: json["minExperience"] as int?,
      education: json["education"] as String?,
      location: json["location"] as String?,
    );
  }
}
