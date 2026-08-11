// lib/services/jobs_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';
import '../core/models/job.dart';


// ============================================================================
// USER JOB PROFILE
// ============================================================================

class UserJobProfile {
  final String userId;
  final String occupationCategory;
  final List<String> preferredJobs;

  UserJobProfile({
    required this.userId,
    required this.occupationCategory,
    required this.preferredJobs,
  });
}


// ============================================================================
// JOBS SERVICE
// ============================================================================

class JobsService {

  // ==========================================================================
  // FETCH USER PROFILE
  // ==========================================================================
  //
  // Gets the user's profile using their phone number.
  //
  // Expected backend response:
  //
  // {
  //   "success": true,
  //   "user_id": "796e7d81-3f8c-4a8e-a21f-a815d55c7fe7",
  //   "occupation_category": "Mason",
  //   "preferred_jobs": []
  // }
  //
  // ==========================================================================

  Future<UserJobProfile> fetchUserProfile({
    required String phone,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/users/profile",
      ).replace(
        queryParameters: {
          "phone": phone,
        },
      );

      developer.log(
        "=== fetchUserProfile() ===",
      );

      developer.log(
        "Request: $uri",
      );

      final response = await http.get(uri);

      developer.log(
        "Status: ${response.statusCode}",
      );

      developer.log(
        "Response: ${response.body}",
      );

      if (response.statusCode != 200) {
        developer.log(
          "fetchUserProfile failed: ${response.statusCode}",
        );

        return UserJobProfile(
          userId: '',
          occupationCategory: '',
          preferredJobs: [],
        );
      }

      final data = jsonDecode(response.body);

      return UserJobProfile(
        userId: data["user_id"] ?? '',
        occupationCategory:
            data["occupation_category"] ?? '',
        preferredJobs:
            List<String>.from(data["preferred_jobs"] ?? []),
      );

    } catch (e, s) {
      developer.log(
        "fetchUserProfile Exception: $e",
        stackTrace: s,
      );

      return UserJobProfile(
        userId: '',
        occupationCategory: '',
        preferredJobs: [],
      );
    }
  }


  // ==========================================================================
  // FETCH RECOMMENDED JOBS
  // ==========================================================================
  //
  // IMPORTANT:
  // Flutter does NOT filter jobs anymore.
  //
  // Backend decides which jobs belong in the feed.
  //
  // Backend rules:
  //
  // 1. Jobs belonging to user's occupation
  // 2. Then all unskilled jobs
  //
  // Example:
  //
  // User occupation = Mason
  //
  // Response:
  //
  // Mason job 1
  // Mason job 2
  // Mason job 3
  // Security
  // General Labour
  // Housekeeping
  //
  // ==========================================================================

  Future<List<Job>> fetchRecommendedJobs({
    required String userId,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/recommended-jobs",
      ).replace(
        queryParameters: {
          "user_id": userId,
        },
      );

      developer.log(
        "=== fetchRecommendedJobs() ===",
      );

      developer.log(
        "Request: $uri",
      );

      final response = await http.get(uri);

      developer.log(
        "Status: ${response.statusCode}",
      );

      developer.log(
        "Response: ${response.body}",
      );

      if (response.statusCode != 200) {
        developer.log(
          "fetchRecommendedJobs failed: ${response.statusCode}",
        );

        return [];
      }

      final data = jsonDecode(response.body);

      final List jobs = data["jobs"] ?? [];

      return jobs
          .map(
            (json) => Job.fromJson(json),
          )
          .toList();

    } catch (e, s) {
      developer.log(
        "fetchRecommendedJobs Exception: $e",
        stackTrace: s,
      );

      return [];
    }
  }

  // ==========================================================================
  // FETCH JOB DETAIL
  // ==========================================================================
  //
  // 🚧 DB INTEGRATION POINT 🚧
  // DB TEAM: called when the user taps a job card. PLACEHOLDER route below
  // — confirm the real path (guessing /jobs/{id}) and adjust if different.
  // Expected response: a single job object, same shape as the items inside
  // "jobs" from fetchRecommendedJobs (parsed by Job.fromJson).
  // ==========================================================================

  Future<Job?> fetchJobDetail({required String jobId}) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/jobs/$jobId");

      developer.log("=== fetchJobDetail() ===");
      developer.log("Request: $uri");

      final response = await http.get(uri);

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      if (response.statusCode != 200) {
        developer.log("fetchJobDetail failed: ${response.statusCode}");
        return null;
      }

      final data = jsonDecode(response.body);

      // Handles both a bare job object and one wrapped as {"job": {...}}.
      final jobJson = data is Map<String, dynamic> && data.containsKey('job')
          ? data['job']
          : data;

      return Job.fromJson(jobJson);
    } catch (e, s) {
      developer.log("fetchJobDetail Exception: $e", stackTrace: s);
      return null;
    }
  }
}

