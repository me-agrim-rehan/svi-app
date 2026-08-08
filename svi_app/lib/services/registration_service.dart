// lib/services/registration_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';

class RegistrationService {
  Future<bool> createAccount({
    required String phone,
    required String name,
    required String address,
    required String city,
    required String state,
    required String occupation,
    required String description,
    required String aadhaarNumber,
    required String aadhaarPhotoUrl,
    required String livePhotoUrl,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/registration/create-account",
      );

      developer.log("=== createAccount() called ===");
      developer.log("Request URI: $uri");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "name": name,
          "address": address,
          "city": city,
          "state": state,
          // NOTE: `occupation` is currently the raw string typed/selected in
          // the autocomplete field, e.g. "Mason (Brickwork)". DB guy: decide
          // whether you want this split into category + subrole on the
          // backend, or sent as one string. See occupation_data.dart.
          "occupation": occupation,
          "description": description,
          "aadhaarNumber": aadhaarNumber,
          "aadhaarPhotoUrl": aadhaarPhotoUrl,
          "livePhotoUrl": livePhotoUrl,
        }),
      );

      developer.log("Status: ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e, s) {
      developer.log("submitPersonalInfo Exception: $e", stackTrace: s);
      return false;
    }
  }

  /// Step 3 (Documents page): Aadhaar photo + selfie.
  /// PLACEHOLDER endpoint: POST /register/documents
  /// NOTE: no real files are wired up yet (upload/camera buttons just show
  /// a snackbar). Once image picker is added, this needs to become a
  /// multipart request (http.MultipartRequest) carrying the actual files,
  /// not a plain JSON POST.
  Future<bool> submitDocuments({
    required String phone,
  }) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/register/documents");
      developer.log("=== submitDocuments() called ===");
      developer.log("Request URI: $uri");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          // TODO(DB/BACKEND): replace with actual file upload (multipart)
          // once image picker / camera capture is implemented.
        }),
      );

      developer.log("Status: ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e, s) {
      developer.log("submitDocuments Exception: $e", stackTrace: s);
      return false;
    }
  }
}