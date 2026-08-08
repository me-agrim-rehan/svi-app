// lib/services/registration_service.dart
import 'dart:convert';
import 'dart:developer' as developer;

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
          "occupation": occupation,
          "description": description,
          "aadhaarNumber": aadhaarNumber,
          "aadhaarPhotoUrl": aadhaarPhotoUrl,
          "livePhotoUrl": livePhotoUrl,
        }),
      );

      developer.log(
        "Status Code: ${response.statusCode}",
      );

      developer.log(
        "Response Body: ${response.body}",
      );

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e, s) {
      developer.log(
        "createAccount Exception: $e",
        stackTrace: s,
      );

      return false;
    }
  }
}