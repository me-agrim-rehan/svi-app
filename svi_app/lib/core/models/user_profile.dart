class UserProfile {
  final String userId;
  final String phone;
  final String name;
  final String occupation;
  final String yearsOfExperience;
  final List<String> preferredJobs;
  final String? profilePhotoUrl;

  UserProfile({
    required this.userId,
    required this.phone,
    required this.name,
    required this.occupation,
    required this.yearsOfExperience,
    required this.preferredJobs,
    this.profilePhotoUrl,
  });

  // ==========================================================================
  // 🚧 DB INTEGRATION POINT 🚧
  // DB TEAM: adjust key names to match your actual API response shape.
  // ==========================================================================

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      occupation:
          json['occupation_category'] ??
          json['occupation'] ??
          '',
      yearsOfExperience:
          (json['years_of_experience'] ?? '').toString(),
      preferredJobs:
          List<String>.from(json['preferred_jobs'] ?? []),
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? occupation,
    String? yearsOfExperience,
    List<String>? preferredJobs,
    String? profilePhotoUrl,
  }) {
    return UserProfile(
      userId: userId,
      phone: phone,
      name: name ?? this.name,
      occupation: occupation ?? this.occupation,
      yearsOfExperience:
          yearsOfExperience ?? this.yearsOfExperience,
      preferredJobs:
          preferredJobs ?? this.preferredJobs,
      profilePhotoUrl:
          profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}