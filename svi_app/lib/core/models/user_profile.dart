class UserProfile {
  final String userId;
  final String phone;
  final String name;
  final String address;
  final String city;
  final String state;
  final String occupation;
  final String yearsOfExperience;
  final String description;
  final List<String> preferredJobs;
  final String? profilePhotoUrl;

  UserProfile({
    required this.userId,
    required this.phone,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.occupation,
    required this.yearsOfExperience,
    required this.description,
    required this.preferredJobs,
    this.profilePhotoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      occupation:
          json['occupation_category'] ??
          json['occupation'] ??
          '',
      yearsOfExperience:
          (json['years_of_experience'] ?? '').toString(),
      description: json['description'] ?? '',
      preferredJobs:
          List<String>.from(json['preferred_jobs'] ?? []),
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? address,
    String? city,
    String? state,
    String? occupation,
    String? yearsOfExperience,
    String? description,
    List<String>? preferredJobs,
    String? profilePhotoUrl,
  }) {
    return UserProfile(
      userId: userId,
      phone: phone,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      occupation: occupation ?? this.occupation,
      yearsOfExperience:
          yearsOfExperience ?? this.yearsOfExperience,
      description: description ?? this.description,
      preferredJobs:
          preferredJobs ?? this.preferredJobs,
      profilePhotoUrl:
          profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}