class UserModel {
  final String name;
  final String email;
  final String? profileImageUrl;
  final String role;

  UserModel({
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.role = 'Student', // Default role
  });
}
