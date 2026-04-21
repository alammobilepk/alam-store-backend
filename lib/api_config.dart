import 'package:flutter/foundation.dart';

class ApiConfig {
  // AGAR CHROME HAI TOH LOCALHOST, AGAR PHONE HAI TOH APNA IP ADDRESS LIKHEIN
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api/auth";
    } else {
      return "http://192.168.100.11:3000/api/auth"; // <--- Yahan apna IPv4 address likhein
    }
  }
  static String get sendOtp => "$baseUrl/send-otp";
  static String get register => "$baseUrl/register";
}