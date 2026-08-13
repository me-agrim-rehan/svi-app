// lib/services/docs_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/network/api_constants.dart';
import '../core/models/app_document.dart';

class DocsService {
  /// GET /users/documents?phone={phone}
  /// GET /offer/my-documents?phone={phone}
Future<List<AppDocument>> fetchDocuments({
  required String phone,
}) async {
  try {
    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/offer/my-documents",
    ).replace(
      queryParameters: {
        "phone": phone,
      },
    );

    developer.log("=== fetchDocuments() ===");
    developer.log("Request: $uri");

    final response = await http.get(uri);

    developer.log("Status: ${response.statusCode}");
    developer.log("Response: ${response.body}");

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);

    final List docs = data["documents"] ?? [];

    return docs
        .map((json) => AppDocument.fromJson(json))
        .toList();
  } catch (e, s) {
    developer.log(
      "fetchDocuments Exception: $e",
      stackTrace: s,
    );

    return [];
  }
}

  /// POST /signed-documents/upload
  ///
  /// Uploads:
  /// - PDF
  /// - PNG
  /// - JPG
  /// - JPEG
  ///
  /// The backend stores the actual file.
  /// The database stores only the file URL.
  Future<bool> uploadSignedCertificate({
    required String phone,
    required PlatformFile file,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/signed-documents/upload",
      );

      developer.log("========================================");
      developer.log("SIGNED DOCUMENT UPLOAD");
      developer.log("URL: $uri");
      developer.log("Phone: $phone");
      developer.log("File name: ${file.name}");
      developer.log("File extension: ${file.extension}");
      developer.log("File size: ${file.bytes?.length}");
      developer.log("========================================");

      if (file.bytes == null) {
        developer.log("ERROR: File bytes are null.");
        return false;
      }

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["phone"] = phone;

      // Determine the correct MIME type.
      String? mimeType;

      switch (file.extension?.toLowerCase()) {
        case "pdf":
          mimeType = "application/pdf";
          break;

        case "png":
          mimeType = "image/png";
          break;

        case "jpg":
        case "jpeg":
          mimeType = "image/jpeg";
          break;
      }

      if (mimeType == null) {
        developer.log(
          "ERROR: Unsupported file type: ${file.extension}",
        );
        return false;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      developer.log("Multipart request created.");
      developer.log("Fields: ${request.fields}");
      developer.log("Number of files: ${request.files.length}");
      developer.log("File field: ${request.files.first.field}");
      developer.log(
        "Multipart filename: ${request.files.first.filename}",
      );
      developer.log("MIME type: $mimeType");
      developer.log("Sending request...");

      final streamedResponse = await request.send();

      developer.log("Request completed.");

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log("Status: ${response.statusCode}");
      developer.log("Response: ${response.body}");
      developer.log("========================================");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log(
        "uploadSignedCertificate Exception: $e",
        stackTrace: s,
      );

      return false;
    }
  }
}