// lib/core/models/applied_job.dart

enum ApplicationStatus { processing, accepted, rejected }

class AppliedJob {
  final String applicationId;
  final String jobId;
  final String title;
  final String companyName;
  final String location;
  final String jobType;
  final String salaryRange;
  final ApplicationStatus status;

  AppliedJob({
    required this.applicationId,
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.salaryRange,
    required this.status,
  });

  // ==========================================================================
  // 🚧 DB INTEGRATION POINT 🚧
  // DB TEAM: matches the "status" column on user_applied_jobs
  // ('processing' | 'accepted' | 'rejected'). Adjust field names to match
  // whatever GET /jobs/applied actually returns — this assumes each row
  // includes the joined job details (title/company/etc), not just the raw
  // application row.
  // ==========================================================================
  factory AppliedJob.fromJson(Map<String, dynamic> json) {
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

    ApplicationStatus parseStatus(String? raw) {
      switch (raw?.toLowerCase()) {
        case 'accepted':
          return ApplicationStatus.accepted;
        case 'rejected':
          return ApplicationStatus.rejected;
        default:
          return ApplicationStatus.processing;
      }
    }

    return AppliedJob(
      applicationId: json['id'].toString(),
      jobId: json['job_id'].toString(),
      title: json['name'] ?? json['title'] ?? '',
      companyName: json['company'] ?? '',
      location: json['work_location'] ?? '',
      jobType: json['job_type'] ?? '',
      salaryRange: salaryRange,
      status: parseStatus(json['status']),
    );
  }
}