import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';

class LoginService {
  /// Send OTP for an existing account
  Future<bool> sendLoginOtp(String phone) async {
    try {
      developer.log("=== sendLoginOtp() called ===");
      developer.log("Phone: $phone");

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/auth/login/send-otp",
      );

      developer.log("Request URI: $uri");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
        }),
      );

      developer.log("Status Code: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log(
        "sendLoginOtp Exception",
        error: e,
        stackTrace: s,
      );

      return false;
    }
  }

  /// Verify OTP for an existing account
  Future<bool> verifyLoginOtp(
    String phone,
    String otp,
  ) async {
    try {
      developer.log("=== verifyLoginOtp() called ===");

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/auth/login/verify-otp",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      developer.log("Status Code: ${response.statusCode}");
      developer.log("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log(
        "verifyLoginOtp Exception",
        error: e,
        stackTrace: s,
      );

      return false;
    }
  }
}