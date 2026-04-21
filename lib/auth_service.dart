import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  // 1. OTP Mangwanay ka function (Email bhejain ge)
  static Future<Map<String, dynamic>> requestOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "Connection fail: $e"};
    }
  }

  // 2. Signup Function (Email, OTP, Password, Phone sub bhejain ge)
  static Future<Map<String, dynamic>> verifyAndRegister({
    required String email,
    required String otp,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "password": password,
          "phone": phone
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "Connection fail: $e"};
    }
  }
}