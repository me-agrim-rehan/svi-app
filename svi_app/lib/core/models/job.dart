// lib/core/models/job.dart

enum JobSkillLevel { skilled, unskilled }

class Job {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final String location;
  final String jobType;
  final String workMode;
  final String salaryRange;
  final String category;       // e.g. "Electrician"
  final String subCategory;    // e.g. "Cable Puller" — empty string if not applicable
  final JobSkillLevel skillLevel;
  bool isBookmarked;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.location,
    required this.jobType,
    required this.workMode,
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
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      companyName: json['company_name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      jobType: json['job_type'] ?? '',
      workMode: json['work_mode'] ?? '',
      salaryRange: json['salary_range'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      skillLevel: (json['skill_level'] == 'unskilled')
          ? JobSkillLevel.unskilled
          : JobSkillLevel.skilled,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }
}