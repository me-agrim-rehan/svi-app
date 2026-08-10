import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/network/api_constants.dart';
import '../core/models/user_profile.dart';

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

  /// PATCH /users/profile — update name.
  Future<bool> updateName({
    required String phone,
    required String name,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "name": name,
      },
    );
  }

  /// PATCH /users/profile — update address.
  Future<bool> updateAddress({
    required String phone,
    required String address,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "address": address,
      },
    );
  }

  /// PATCH /users/profile — update city.
  Future<bool> updateCity({
    required String phone,
    required String city,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "city": city,
      },
    );
  }

  /// PATCH /users/profile — update state.
  Future<bool> updateState({
    required String phone,
    required String state,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "state": state,
      },
    );
  }

  /// PATCH /users/profile — update occupation.
  Future<bool> updateOccupation({
    required String phone,
    required String occupation,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "occupation": occupation,
      },
    );
  }

  /// PATCH /users/profile — update years of experience.
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

  /// PATCH /users/profile — update description.
  Future<bool> updateDescription({
    required String phone,
    required String description,
  }) async {
    return _patchProfile(
      phone: phone,
      body: {
        "description": description,
      },
    );
  }

  /// PATCH /users/profile — update preferred jobs.
  Future<bool> updatePreferredJobs({
    required String phone,
    required List<String> preferredJobs,
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

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e, s) {
      developer.log(
        "_patchProfile Exception: $e",
        stackTrace: s,
      );

      if (kDebugMode) {
        print("Profile update error: $e");
      }

      return false;
    }
  }

  /// POST /users/profile-photo
  /// Upload a new profile picture.
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