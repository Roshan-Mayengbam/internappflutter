class UserModel {
  final String name;
  final String email;
  final String? phone;
  final String uid;
  final String role;

  UserModel({
    required this.name,
    required this.email,
    this.phone,
    required this.uid,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uid': uid,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      phone: map['phone'],
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'Student',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, phone: $phone, uid: $uid, role: $role)';
  }
}

class ExtendedUserModel extends UserModel {
  final String collegeName;
  final String university;
  final String degree;
  final String collegeEmailId;
  final List<String> skills;
  final List<String> jobs;

  ExtendedUserModel({
    required super.name,
    required super.email,
    super.phone,
    required super.uid,
    required super.role,
    required this.collegeName,
    required this.university,
    required this.degree,
    required this.collegeEmailId,
    this.skills = const [],
    this.jobs = const [],
  });

  ExtendedUserModel.fromUserModel(
    UserModel user, {
    required this.collegeName,
    required this.university,
    required this.degree,
    required this.collegeEmailId,
    this.skills = const [],
    this.jobs = const [],
  }) : super(
         name: user.name,
         email: user.email,
         phone: user.phone,
         uid: user.uid,
         role: user.role,
       );

  factory ExtendedUserModel.fromMap(Map<String, dynamic> map) {
    return ExtendedUserModel(
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      phone: map['phone'],
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'Student',
      collegeName: map['collegeName'] ?? '',
      university: map['university'] ?? '',
      degree: map['degree'] ?? '',
      collegeEmailId: map['collegeEmailId'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      jobs: List<String>.from(map['jobs'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'collegeName': collegeName,
      'university': university,
      'degree': degree,
      'collegeEmailId': collegeEmailId,
      'skills': skills,
      'jobs': jobs,
    });
    return baseMap;
  }

  @override
  String toString() {
    return 'ExtendedUserModel(${super.toString()}, '
        'collegeName: $collegeName, university: $university, degree: $degree, '
        'collegeEmailId: $collegeEmailId, skills: $skills, jobs: $jobs)';
  }
}

class CourseRange extends ExtendedUserModel {
  final String year;

  CourseRange({
    required this.year,
    required super.name,
    required super.email,
    super.phone,
    required super.uid,
    required super.role,
    required super.collegeName,
    required super.university,
    required super.degree,
    required super.collegeEmailId,
    super.skills = const [],
    super.jobs = const [],
  });

  CourseRange.fromExtended(ExtendedUserModel extendedUser, {required this.year})
    : super(
        name: extendedUser.name,
        email: extendedUser.email,
        phone: extendedUser.phone,
        uid: extendedUser.uid,
        role: extendedUser.role,
        collegeName: extendedUser.collegeName,
        university: extendedUser.university,
        degree: extendedUser.degree,
        collegeEmailId: extendedUser.collegeEmailId,
        skills: extendedUser.skills,
        jobs: extendedUser.jobs,
      );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({'year': year});
    return baseMap;
  }

  @override
  String toString() {
    return 'CourseRange(${super.toString()}, year: $year)';
  }
}

class UserWithSkills extends CourseRange {
  final List<String> userSkills;
  final List<String> preferences;

  UserWithSkills({
    required super.year,
    required super.name,
    required super.email,
    super.phone,
    required super.uid,
    required super.role,
    required super.collegeName,
    required super.university,
    required super.degree,
    required super.collegeEmailId,
    super.skills = const [], // inherited skills from ExtendedUserModel
    super.jobs = const [],
    required this.userSkills, // UserWithSkills specific skills
    required this.preferences,
  });

  /// Named constructor: create from `ExtendedUserModel` + skills
  UserWithSkills.fromExtended(
    ExtendedUserModel extendedUser, {
    required this.userSkills,
    required this.preferences,
    required String year,
  }) : super(
         year: year,
         name: extendedUser.name,
         email: extendedUser.email,
         phone: extendedUser.phone,
         uid: extendedUser.uid,
         role: extendedUser.role,
         collegeName: extendedUser.collegeName,
         university: extendedUser.university,
         degree: extendedUser.degree,
         collegeEmailId: extendedUser.collegeEmailId,
         skills: extendedUser.skills,
         jobs: extendedUser.jobs,
       );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'userSkills': userSkills, // Use the renamed field
      'preferences': preferences,
    });
    return baseMap;
  }

  @override
  String toString() {
    return 'UserWithSkills(${super.toString()}, userSkills: $userSkills, preferences: $preferences)';
  }
}

class UserExperience extends UserWithSkills {
  final String organisation;
  final String position;
  final String date;
  final String description;

  UserExperience({
    required this.organisation,
    required this.position,
    required this.date,
    required this.description,
    required super.year,
    required super.name,
    required super.email,
    super.phone,
    required super.uid,
    required super.role,
    required super.collegeName,
    required super.university,
    required super.degree,
    required super.collegeEmailId,
    super.skills = const [],
    super.jobs = const [],
    required super.userSkills,
    required super.preferences,
  });

  UserExperience.fromUserWithSkills(
    UserWithSkills user, {
    required this.organisation,
    required this.position,
    required this.date,
    required this.description,
  }) : super(
         year: user.year,
         name: user.name,
         email: user.email,
         phone: user.phone,
         uid: user.uid,
         role: user.role,
         collegeName: user.collegeName,
         university: user.university,
         degree: user.degree,
         collegeEmailId: user.collegeEmailId,
         skills: user.skills,
         jobs: user.jobs,
         userSkills: user.userSkills, // Use the renamed field
         preferences: user.preferences,
       );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'organisation': organisation,
      'position': position,
      'date': date,
      'description': description,
    });
    return baseMap;
  }

  @override
  String toString() {
    return 'UserExperience(${super.toString()}, '
        'organisation: $organisation, position: $position, '
        'date: $date, description: $description)';
  }
}

class UserProject extends UserExperience {
  final String projectName;
  final String projectLink;
  final String projectDescription;

  UserProject({
    required this.projectName,
    required this.projectLink,
    required this.projectDescription,
    required super.organisation,
    required super.position,
    required super.date,
    required super.description,
    required super.year,
    required super.name,
    required super.email,
    super.phone,
    required super.uid,
    required super.role,
    required super.collegeName,
    required super.university,
    required super.degree,
    required super.collegeEmailId,
    required super.userSkills,
    required super.preferences,
  });

  UserProject.fromUserExperience(
    UserExperience experience, {
    required this.projectName,
    required this.projectLink,
    required this.projectDescription,
  }) : super(
         organisation: experience.organisation,
         position: experience.position,
         date: experience.date,
         description: experience.description,
         year: experience.year,
         name: experience.name,
         email: experience.email,
         phone: experience.phone,
         uid: experience.uid,
         role: experience.role,
         collegeName: experience.collegeName,
         university: experience.university,
         degree: experience.degree,
         collegeEmailId: experience.collegeEmailId,
         userSkills: experience.userSkills,
         preferences: experience.preferences,
       );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'projectName': projectName,
      'projectLink': projectLink,
      'projectDescription': projectDescription,
    });
    return map;
  }

  @override
  String toString() {
    return 'UserProject(${super.toString()}, projectName: $projectName, projectLink: $projectLink, projectDescription: $projectDescription)';
  }
}

class UploadResume extends UserProject {
  final String profilePic;
  final String resumeFile;

  UploadResume({
    required this.profilePic,
    required this.resumeFile,
    required super.projectName,
    required super.projectLink,
    required super.projectDescription,
    required super.organisation,
    required super.position,
    required super.date,
    required super.description,
    required super.year,
    required super.name,
    required super.email,
    super.phone, // ✅ Fixed: Added phone parameter
    required super.uid,
    required super.role,
    required super.collegeName,
    required super.university,
    required super.degree,
    required super.collegeEmailId,
    required super.userSkills,
    required super.preferences,
  });

  /// Create UploadResume from UserProject
  UploadResume.fromUserProject(
    UserProject project, {
    required this.profilePic,
    required this.resumeFile,
  }) : super(
         projectName: project.projectName,
         projectLink: project.projectLink,
         projectDescription: project.projectDescription,
         organisation: project.organisation,
         position: project.position,
         date: project.date,
         description: project.description,
         year: project.year,
         name: project.name,
         email: project.email,
         phone: project.phone, // ✅ Fixed: Pass phone through
         uid: project.uid,
         role: project.role,
         collegeName: project.collegeName,
         university: project.university,
         degree: project.degree,
         collegeEmailId: project.collegeEmailId,
         userSkills: project.userSkills,
         preferences: project.preferences,
       );

  /// Convert to JSON (for API / DB)
  @override
  Map<String, dynamic> toMap() {
    return {
      "profilePic": profilePic,
      "resumeFile": resumeFile,
      "projectName": projectName,
      "projectLink": projectLink,
      "projectDescription": projectDescription,
      "organisation": organisation,
      "position": position,
      "date": date,
      "description": description,
      "year": year,
      "name": name,
      "email": email,
      "phone": phone, // ✅ Fixed: Added phone to JSON
      "uid": uid,
      "role": role,
      "collegeName": collegeName,
      "university": university,
      "degree": degree,
      "collegeEmailId": collegeEmailId,
      "userSkills": userSkills,
      "preferences": preferences,
    };
  }

  /// Alternative JSON method for API compatibility
  Map<String, dynamic> toJson() => toMap();

  /// Factory for creating from JSON/Map
  factory UploadResume.fromMap(Map<String, dynamic> map) {
    return UploadResume(
      profilePic: map["profilePic"] ?? "",
      resumeFile: map["resumeFile"] ?? "",
      projectName: map["projectName"] ?? "",
      projectLink: map["projectLink"] ?? "",
      projectDescription: map["projectDescription"] ?? "",
      organisation: map["organisation"] ?? "",
      position: map["position"] ?? "",
      date: map["date"] ?? "",
      description: map["description"] ?? "",
      year: map["year"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"], // ✅ Fixed: Added phone from JSON
      uid: map["uid"] ?? "",
      role: map["role"] ?? "",
      collegeName: map["collegeName"] ?? "",
      university: map["university"] ?? "",
      degree: map["degree"] ?? "",
      collegeEmailId: map["collegeEmailId"],
      userSkills: List<String>.from(map["userSkills"] ?? []),
      preferences: List<String>.from(map["preferences"] ?? []),
    );
  }

  /// Factory for creating from JSON (alternative method)
  factory UploadResume.fromJson(Map<String, dynamic> json) =>
      UploadResume.fromMap(json);

  @override
  String toString() {
    return 'UploadResume(${super.toString()}, profilePic: $profilePic, resumeFile: $resumeFile)';
  }
}
