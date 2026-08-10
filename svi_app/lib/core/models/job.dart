// lib/core/models/job.dart

enum JobSkillLevel { skilled, unskilled }

class Job {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final String location;
  final String jobType;
  final String salaryRange;
  final String category; // e.g. "Electrician"
  final String
  subCategory; // e.g. "Cable Puller" — empty string if not applicable
  final JobSkillLevel skillLevel;
  bool isBookmarked;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.location,
    required this.jobType,
    required this.salaryRange,
    required this.category,
    required this.subCategory,
    required this.skillLevel,
    this.isBookmarked = false,
  });

  // ==========================================================================
  // 🚧 DB INTEGRATION POINT 🚧
  // DB TEAM: adjust key names to match your actual API job object shape.
  // "skill_level" is expected to be the literal string "skilled" or
  // "unskilled" — matches your category table's skilled/unskilled flag.
  // ==========================================================================
  factory Job.fromJson(Map<String, dynamic> json) {
    final salaryMin = json['salary_min'];
    final salaryMax = json['salary_max'];

    String salaryRange = '';

    if (salaryMin != null && salaryMax != null) {
      salaryRange = '₹$salaryMin - ₹$salaryMax';
    } else if (salaryMin != null) {
      salaryRange = '₹$salaryMin+';
    } else if (salaryMax != null) {
      salaryRange = 'Up to ₹$salaryMax';
    }

    return Job(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      companyName: json['company'] ?? '',
      description: json['description'] ?? '',
      location: json['work_location'] ?? '',
      jobType: json['job_type'] ?? '',
      salaryRange: salaryRange,
      category: json['category'] ?? '',
      subCategory: json['subcategory'] ?? '',
      skillLevel: (json['skill_type']?.toString().toLowerCase() == 'unskilled')
          ? JobSkillLevel.unskilled
          : JobSkillLevel.skilled,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }
}