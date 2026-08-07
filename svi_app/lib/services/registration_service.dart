// lib/services/registration_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';

// ============================================================================
// 🔌 BACKEND INTEGRATION POINT — REGISTRATION ENDPOINTS
// ------------------------------------------------------------------------
// Every URL/path below is a PLACEHOLDER guess (/register/...). None of these
// are awaited or gated on in the UI yet — they fire in the background so the
// screens work standalone. When the real backend is ready:
//   1. Fix the paths to match the actual routes.
//   2. Fix the request bodies to match what the backend expects.
//   3. In register_screen.dart, change fire-and-forget calls to `await` +
//      handle success/failure (same pattern already used for sendOtp/verifyOtp
//      in AuthService / LoginScreen).
// ============================================================================
class RegistrationService {
  /// Step 1 (Verification page): Aadhaar number submission.
  /// PLACEHOLDER endpoint: POST /register/aadhaar
  Future<bool> submitAadhaarNumber({
    required String phone,
    required String aadhaarNumber,
  }) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/register/aadhaar");
      developer.log("=== submitAadhaarNumber() called ===");
      developer.log("Request URI: $uri");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "aadhaar_number": aadhaarNumber,
        }),
      );

      developer.log("Status: ${response.statusCode}, Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e, s) {
      developer.log("submitAadhaarNumber Exception: $e", stackTrace: s);
      return false;
    }
  }

  /// Step 2 (Personal Info page): name, address, city, state, occupation, description.
  /// PLACEHOLDER endpoint: POST /register/personal-info
  Future<bool> submitPersonalInfo({
    required String name,
    required String address,
    required String city,
    required String state,
    required String occupation,
    required String description,
  }) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/register/personal-info");
      developer.log("=== submitPersonalInfo() called ===");
      developer.log("Request URI: $uri");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
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