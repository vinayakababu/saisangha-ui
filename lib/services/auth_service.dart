import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const _baseUrl = "http://192.168.1.7:8080"; // adjust for emulator/device
  static const _storage = FlutterSecureStorage();

  /// Login and save JWT token
  static Future<bool> login(String username, String password) async {
    print("Attempting login for user: $username");
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
print("Login response==========================: ${response.statusCode} - ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _storage.write(key: "jwt", value: token);
      print("Login success, token saved: $token");
      return true;
    } else {
      print("Login failed: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  /// Fetch dashboard data using stored JWT
  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await _storage.read(key: "jwt");
    print("Fetching dashboard with token ================== : $token");
    if (token == null) {
      print("No token found, please login first.");
      return {
        "error": "No token found",
        "body": null,
        "role": null
      };
    }

    final response = await http.get(
      Uri.parse("$_baseUrl/api/dashBoard"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Dashboard data: ${response.body}");
      final decodedToken = JwtDecoder.decode(token); 
      print(  "Decoded JWT token: $decodedToken ================== ");
      final role = decodedToken['roles'];
      print(  "Extracted role from token: $role ================== ");
      return {
        "body": response.body,
        "role": role,
        "error": null
      };
    } else {
      print("Dashboard failed: ${response.statusCode} - ${response.body}");
      return {
        "error": "Failed to fetch dashboard",
        "body": null,
        "role": null
      };
    }
  }

  /// Logout (clear token)
  static Future<void> logout() async {
    await _storage.delete(key: "jwt");
    print("Logged out, token cleared.");
  }

  /// Utility: check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: "jwt");
    return token != null;
  }

  static Future<bool> createUser(Map<String, dynamic> userData) async {
  try {
    final token = await _storage.read(key: "jwt");
    print("Sending token: $token");

    final response = await http.post(
      Uri.parse("$_baseUrl/api/user/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(userData),
    );

    print("CreateUser response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("CreateUser exception: $e");
    return false;
  }
}

}
