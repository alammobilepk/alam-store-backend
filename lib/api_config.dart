import 'package:flutter/foundation.dart';

class ApiConfig {
  // Ab aapka backend Vercel par live hai, toh IP address ki zaroorat nahi
  static const String baseUrl = "https://alam-store.vercel.app/api/auth";

  static String get sendOtp => "$baseUrl/send-otp";
  static String get register => "$baseUrl/register";
}