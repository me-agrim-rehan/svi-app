// lib/services/docs_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/network/api_constants.dart';
import '../core/models/app_document.dart';

// ============================================================================
// 🔌 BACKEND INTEGRATION POINT — DOCUMENTS
// ------------------------------------------------------------------------
// DB/BACKEND TEAM: both routes below are PLACEHOLDER guesses. Confirm the
// real paths and adjust.
// ============================================================================
class DocsService {
  /// GET /users/documents?phone={phone}
  /// Expected: a list of downloadable PDFs (e.g. offer letters).
  Future<List<AppDocument>> fetchDocuments({required String phone}) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/users/documents",
      ).replace(queryParameters: {"phone": phone});

      developer.log("=== fetchDocuments() ===");
      developer.log("Request: $uri");

      final response = await http.get(uri);

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final List docs = data["documents"] ?? [];

      return docs.map((json) => AppDocument.fromJson(json)).toList();
    } catch (e, s) {
      developer.log("fetchDocuments Exception: $e", stackTrace: s);
      return [];
    }
  }

  /// POST /users/signed-certificate — multipart upload for a photo of a
  /// signed certificate/document.
  Future<bool> uploadSignedCertificate({
    required String phone,
    required XFile photo,
  }) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/users/signed-certificate");

      developer.log("=== uploadSignedCertificate() ===");
      developer.log("Request: $uri");

      final bytes = await photo.readAsBytes();

      final request = http.MultipartRequest("POST", uri);
      request.fields["phone"] = phone;
      request.files.add(
        http.MultipartFile.fromBytes("photo", bytes, filename: photo.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log("uploadSignedCertificate Exception: $e", stackTrace: s);
      return false;
    }
  }
}