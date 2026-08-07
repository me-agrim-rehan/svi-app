// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/network/api_constants.dart';

class AuthService {
  /// Send OTP
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/otp/send-otp"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },

        body: jsonEncode({"phone": phone}),
      );

      developer.log(
        'Send OTP status code: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log('Send OTP response: ${response.body}', name: 'AuthService');

      return response.statusCode == 200;
    } catch (e, s) {
      developer.log(
        'Send OTP Error',
        error: e,
        stackTrace: s,
        name: 'AuthService',
      );
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
