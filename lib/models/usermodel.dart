class UserModel {
  final String name;
  final String email;
  final String? phone; // Made nullable since Google might not provide phone
  final String? profileImageUrl;
  final String uid; // Added UID for future reference
  final String role;

  UserModel({
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.uid,
    required this.role,
  });

  // Convert to Map for easy data handling
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'uid': uid,
      'role': role,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'Student',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, phone: $phone, profileImageUrl: $profileImageUrl, uid: $uid, role: $role)';
  }
}
