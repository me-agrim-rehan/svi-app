import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/network/api_constants.dart';
import '../core/models/user_profile.dart';

// ============================================================================
// 🔌 BACKEND INTEGRATION POINT — PROFILE
// ------------------------------------------------------------------------
// DB/BACKEND TEAM: every route below is a PLACEHOLDER guess. Confirm/adjust
// paths and field names to match your real API.
// ============================================================================
class ProfileService {
  /// GET /users/profile?phone={phone}
  Future<UserProfile?> fetchProfile({
    required String phone,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/users/profile",
      ).replace(
        queryParameters: {"phone": phone},
      );

      developer.log("=== fetchProfile() ===");
      developer.log("Request: $uri");

      final response = await http.get(uri);

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      return UserProfile.fromJson(data);
    } catch (e, s) {
      developer.log(
        "fetchProfile Exception: $e",
        stackTrace: s,
      );
      return null;
    }
  }

  /// PATCH /users/profile — update name only.
  Future<bool> updateName({
    required String phone,
    required String name,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {"name": name},
    );
  }

  /// PATCH /users/profile — update occupation only.
  Future<bool> updateOccupation({
    required String phone,
    required String occupation,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {"occupation": occupation},
    );
  }

  /// PATCH /users/profile — update years of experience only.
  Future<bool> updateYearsOfExperience({
    required String phone,
    required String yearsOfExperience,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "years_of_experience": yearsOfExperience,
      },
    );
  }

  /// PATCH /users/profile — update preferred jobs list.
  Future<bool> updatePreferredJobs({
    required String phone,
    required List preferredJobs,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "preferred_jobs": preferredJobs,
      },
    );
  }

  Future<bool> _patchProfile({
    required String phone,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/users/profile",
      );

      developer.log("=== _patchProfile() ===");
      developer.log(
        "Request: $uri, body: $body",
      );

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          ...body,
        }),
      );

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log(
        "_patchProfile Exception: $e",
        stackTrace: s,
      );
      return false;
    }
  }

  /// POST /users/profile-photo — multipart upload for the profile picture.
  /// Returns the new photo URL on success, or null on failure.
  Future<String?> updateProfilePhoto({
    required String phone,
    required XFile photo,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/users/profile-photo",
      );

      developer.log("=== updateProfilePhoto() ===");
      developer.log("Request: $uri");

      final bytes = await photo.readAsBytes();

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["phone"] = phone;

      request.files.add(
        http.MultipartFile.fromBytes(
          "photo",
          bytes,
          filename: photo.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      return data['profile_photo_url'] as String?;
    } catch (e, s) {
      developer.log(
        "updateProfilePhoto Exception: $e",
        stackTrace: s,
      );
      return null;
    }
  }
}