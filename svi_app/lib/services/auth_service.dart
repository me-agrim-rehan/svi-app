// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';

class AuthService {
  /// Send OTP
  Future<bool> sendOtp(String phone) async {
    try {
      developer.log("=== sendOtp() called ===");

      developer.log("Phone: $phone");

      developer.log("Base URL: ${ApiConstants.baseUrl}");

      final uri = Uri.parse("${ApiConstants.baseUrl}/otp/send-otp");

      developer.log("Request URI: $uri");
      developer.log("Sending HTTP POST...");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      developer.log("Status Code: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log("sendOtp Exception: $e", stackTrace: s);
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/otp/verify-otp"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e, s) {
      developer.log('Verify OTP Error', error: e, stackTrace: s);
      return false;
    }
  }
}