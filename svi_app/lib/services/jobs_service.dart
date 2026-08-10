// lib/services/jobs_service.dart

import 'dart:developer' as developer;

import '../core/models/job.dart';

// ============================================================================
// 🔌 BACKEND INTEGRATION POINT — JOBS + USER PROFILE
// ------------------------------------------------------------------------
// DB/BACKEND TEAM:
//
// fetchAllJobs(): currently returns MOCK data. Real version should hit
//   something like GET /jobs and return every open job (Job.fromJson shape),
//   including "category", "sub_category", and "skill_level"
//   ("skilled"/"unskilled" from your category table).
//
// fetchUserProfile(): currently returns MOCK data. Real version should hit
//   something like GET /users/profile?phone={phone} and return the user's
//   occupation category + their selected preferred jobs (the same
//   "Category|Subrole" strings saved via submitPreferredJobs during
//   registration). The home screen uses this to prioritize the feed:
//     1. Exact preferred-job matches (Category|Subrole)
//     2. Same occupation category (any subrole)
//     3. All unskilled jobs
//
// Once real endpoints exist: delete the _mock* data below, uncomment the
// real HTTP calls, and nothing in home_screen.dart needs to change — it
// already consumes List<Job> / UserJobProfile the same way either way.
// ============================================================================

class UserJobProfile {
  final String occupationCategory; // e.g. "Electrician"
  final List<String> preferredJobs; // "Category|Subrole" strings

  UserJobProfile({
    required this.occupationCategory,
    required this.preferredJobs,
  });
}

class JobsService {
  Future<List<Job>> fetchAllJobs() async {
    try {
      // ---- REAL CALL (uncomment once backend route exists) ----
      // final uri = Uri.parse("${ApiConstants.baseUrl}/jobs");
      // final response = await http.get(uri);
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = jsonDecode(response.body);
      //   return data.map((json) => Job.fromJson(json)).toList();
      // }
      // return [];

      developer.log("=== fetchAllJobs() called (MOCK) ===");
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockJobs;
    } catch (e, s) {
      developer.log("fetchAllJobs Exception: $e", stackTrace: s);
      return [];
    }
  }

  Future<UserJobProfile> fetchUserProfile({required String phone}) async {
    try {
      // ---- REAL CALL (uncomment once backend route exists) ----
      // final uri = Uri.parse("${ApiConstants.baseUrl}/users/profile?phone=$phone");
      // final response = await http.get(uri);
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return UserJobProfile(
      //     occupationCategory: data['occupation_category'] ?? '',
      //     preferredJobs: List<String>.from(data['preferred_jobs'] ?? []),
      //   );
      // }
      // return UserJobProfile(occupationCategory: '', preferredJobs: []);

      developer.log("=== fetchUserProfile() called (MOCK) ===");
      developer.log("Phone: $phone");
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO(DB): this mock assumes an Electrician who preferred two
      // subroles — replace with the real profile lookup.
      return UserJobProfile(
        occupationCategory: 'Electrician',
        preferredJobs: [
          'Electrician|Cable Puller',
          'Electrician|AC/HVAC Technician',
        ],
      );
    } catch (e, s) {
      developer.log("fetchUserProfile Exception: $e", stackTrace: s);
      return UserJobProfile(occupationCategory: '', preferredJobs: []);
    }
  }

  // TODO(DB): remove this entire block once fetchAllJobs hits a real endpoint.
  static final List<Job> _mockJobs = [
    Job(
      id: '1',
      title: 'AC/HVAC Technician',
      companyName: 'CoolAir Systems',
      description: 'Installation and repair of residential AC units.',
      location: 'Pune',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹19,000 - ₹26,000/mo',
      category: 'Electrician',
      subCategory: 'AC/HVAC Technician',
      skillLevel: JobSkillLevel.skilled,
    ),
    Job(
      id: '2',
      title: 'Cable Puller',
      companyName: 'Prime Builders Pvt Ltd',
      description: 'Structured cabling for a new commercial complex.',
      location: 'Pune',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹17,000 - ₹22,000/mo',
      category: 'Electrician',
      subCategory: 'Cable Puller',
      skillLevel: JobSkillLevel.skilled,
    ),
    Job(
      id: '3',
      title: 'Site Electrician',
      companyName: 'Vertex Infra',
      description: 'General wiring and panel work for a residential site.',
      location: 'Mumbai',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹18,000 - ₹25,000/mo',
      category: 'Electrician',
      subCategory: 'Electrician',
      skillLevel: JobSkillLevel.skilled,
    ),
    Job(
      id: '4',
      title: 'Mason - Brickwork',
      companyName: 'Shree Constructions',
      description: 'Brickwork and plastering for a new site.',
      location: 'Mumbai',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹16,000 - ₹22,000/mo',
      category: 'Mason',
      subCategory: 'Brickwork',
      skillLevel: JobSkillLevel.skilled,
    ),
    Job(
      id: '5',
      title: 'General Helper',
      companyName: 'BuildRight Co',
      description: 'Site helper for material handling and loading.',
      location: 'Pune',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹12,000 - ₹15,000/mo',
      category: 'General Labour',
      subCategory: 'Helper',
      skillLevel: JobSkillLevel.unskilled,
    ),
    Job(
      id: '6',
      title: 'Site Cleaner',
      companyName: 'Vertex Infra',
      description: 'Daily cleanup and debris clearing on active sites.',
      location: 'Pune',
      jobType: 'Part-time',
      workMode: 'On-site',
      salaryRange: '₹10,000 - ₹13,000/mo',
      category: 'General Labour',
      subCategory: 'Site Cleaner',
      skillLevel: JobSkillLevel.unskilled,
    ),
    Job(
      id: '7',
      title: 'Loader',
      companyName: 'Shree Constructions',
      description: 'Loading and unloading construction materials.',
      location: 'Nashik',
      jobType: 'Full-time',
      workMode: 'On-site',
      salaryRange: '₹11,000 - ₹14,000/mo',
      category: 'General Labour',
      subCategory: 'Loader',
      skillLevel: JobSkillLevel.unskilled,
    ),
    Job(
      id: '8',
      title: 'Water Boy',
      companyName: 'Prime Builders Pvt Ltd',
      description: 'Water supply and general assistance on site.',
      location: 'Pune',
      jobType: 'Part-time',
      workMode: 'On-site',
      salaryRange: '₹8,000 - ₹10,000/mo',
      category: 'General Labour',
      subCategory: 'Water Boy',
      skillLevel: JobSkillLevel.unskilled,
    ),
  ];
}