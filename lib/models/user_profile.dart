class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.userName,
    required this.displayName,
    required this.emailVerified,
    this.phoneNumber,
    this.createdAt,
  });

  final String id;
  final String email;
  final String userName;
  final String displayName;
  final bool emailVerified;
  final String? phoneNumber;
  final DateTime? createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String readString(String key) => json[key]?.toString().trim() ?? '';
    bool readBool(String key) {
      final value = json[key];
      if (value is bool) return value;
      if (value == null) return false;
      final normalized = value.toString().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }

    final id = readString('_id').isNotEmpty
        ? readString('_id')
        : (readString('id').isNotEmpty ? readString('id') : readString('userId'));

    final displayName = readString('name').isNotEmpty
        ? readString('name')
        : (readString('fullName').isNotEmpty
            ? readString('fullName')
            : readString('userName'));

    return UserProfile(
      id: id,
      email: readString('email'),
      userName: readString('userName'),
      displayName: displayName,
      emailVerified: readBool('emailVerified') ||
          readBool('isEmailVerified') ||
          readString('emailVerificationStatus').toLowerCase() == 'verified',
      phoneNumber: readString('phoneNumber').isNotEmpty
          ? readString('phoneNumber')
          : null,
      createdAt: DateTime.tryParse(
        readString('createdAt').isNotEmpty
            ? readString('createdAt')
            : readString('created_at'),
      ),
    );
  }
}
