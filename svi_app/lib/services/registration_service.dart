// lib/services/registration_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
    required XFile aadhaarPhoto,
    required XFile livePhoto,
    required List<String> preferredJobs,
  }) async {
    try {
      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/registration/create-account",
      );

      developer.log("=== createAccount() called ===");
      developer.log("Request URI: $uri");

      // Read images into memory.
      // This works on Flutter Web as well as mobile.
      final aadhaarBytes = await aadhaarPhoto.readAsBytes();
      final livePhotoBytes = await livePhoto.readAsBytes();

      final request = http.MultipartRequest("POST", uri);

      // Registration fields
      request.fields["phone"] = phone;
      request.fields["name"] = name;
      request.fields["address"] = address;
      request.fields["city"] = city;
      request.fields["state"] = state;
      request.fields["occupation"] = occupation;
      request.fields["description"] = description;
      request.fields["aadhaarNumber"] = aadhaarNumber;

      // Preferred job subcategory IDs
      request.fields["preferredJobs"] = jsonEncode(preferredJobs);

      // Aadhaar image
      request.files.add(
        http.MultipartFile.fromBytes(
          "aadhaarPhoto",
          aadhaarBytes,
          filename: aadhaarPhoto.name,
        ),
      );

      // Live/selfie image
      request.files.add(
        http.MultipartFile.fromBytes(
          "livePhoto",
          livePhotoBytes,
          filename: livePhoto.name,
        ),
      );

      developer.log("Sending multipart registration request...");
      developer.log(
        "Aadhaar image: ${aadhaarPhoto.name} (${aadhaarBytes.length} bytes)",
      );
      developer.log(
        "Live photo: ${livePhoto.name} (${livePhotoBytes.length} bytes)",
      );
      developer.log("Preferred jobs: $preferredJobs");

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      developer.log(
        "Status: ${response.statusCode}, Body: ${response.body}",
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            developer.log("Account created successfully");
            return true;
          }
        } catch (e) {
          developer.log("Could not parse response JSON: $e");
        }
      }

      return false;
    } catch (e, stackTrace) {
      developer.log(
        "createAccount Exception: $e",
        stackTrace: stackTrace,
      );

      if (kDebugMode) {
        print("Registration error: $e");
      }

      return false;
    }
  }
}