class UserProfile {
  final String fullName;
  final String profilePicture;
  final String bio;
  final Map<String, dynamic> education;
  final String id;
  final String firebaseId;
  final String email;
  final String phone;
  final Map<String, dynamic> userSkills;
  final List<String> jobPreference;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> projects;

  UserProfile({
    required this.fullName,
    required this.profilePicture,
    required this.bio,
    required this.education,
    required this.id,
    required this.firebaseId,
    required this.email,
    required this.phone,
    required this.userSkills,
    required this.jobPreference,
    required this.experience,
    required this.projects,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json["FullName"] ?? "",
      profilePicture: json["profilePicture"] ?? "",
      bio: json["bio"] ?? "",
      education: Map<String, dynamic>.from(json["education"] ?? {}),
      id: json["_id"] ?? "",
      firebaseId: json["firebaseId"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      userSkills: Map<String, dynamic>.from(json["user_skills"] ?? {}),
      jobPreference: List<String>.from(json["job_preference"] ?? []),
      experience: (json["experience"] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      projects: (json["projects"] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "profilePicture": profilePicture,
      "bio": bio,
      "education": education,
      "_id": id,
      "firebaseId": firebaseId,
      "email": email,
      "phone": phone,
      "user_skills": userSkills,
      "job_preference": jobPreference,
      "experience": experience,
      "projects": projects,
    };
  }
}
