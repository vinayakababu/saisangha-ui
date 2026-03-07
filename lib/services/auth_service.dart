import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const _baseUrl = "http://192.168.1.3:8080"; // adjust for emulator/device
  //static const _baseUrl = "https://saisangha-app-b6wp.onrender.com"; // production URL
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

    /// Fetch dashboard summary using stored JWT
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final token = await _storage.read(key: "jwt");
    if (token == null) {
      return {
        "error": "No token found",
        "body": null,
        "role": null
      };
    }

    final response = await http.get(
      Uri.parse("$_baseUrl/api/v1/dashboard/summary"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return {
        "body": response.body,
        "error": null
      };
    } else {
      return {
        "error": "Failed to fetch dashboard summary",
        "body": null
      };
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
      Uri.parse("$_baseUrl/api/v1/dashboard/users"),
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

  /// Fetch user details by ID
  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final token = await _storage.read(key: "jwt");
    if (token == null) {
      return {"error": "No token found", "body": null};
    }

    final response = await http.get(
      Uri.parse("$_baseUrl/api/v1/user/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print(  "User details response: ${response.body} ================== ");
      return {"error": null, "body": response.body, "role": JwtDecoder.decode(token)['roles']};
    } else {
      return {"error": "Failed to fetch user details", "body": null};
    }
  }

/// Add new loan for user
  static Future<Map<String, dynamic>> addLoan(String userId, Map<String, dynamic> payload) async {
    try {
      final token = await _storage.read(key: "jwt");
    if (token == null) {
      return {"error": "No token found", "body": null};
    }
      final response = await http.post(
        Uri.parse("$_baseUrl/api/v1/loans/$userId"),
        headers: {"Authorization": "Bearer $token",
          "Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"body": response.body};
      } else {
        return {"error": "Failed to add loan: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Update existing loan
  static Future<Map<String, dynamic>> updateLoan(
      String userId, String loanId, Map<String, dynamic> payload) async {
    try {
      final token = await _storage.read(key: "jwt");
    if (token == null) {
      return {"error": "No token found", "body": null};
    }
      final response = await http.patch(
        Uri.parse("$_baseUrl/api/v1/loans/$userId/$loanId"),
        headers: {"Authorization": "Bearer $token",
        "Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return {"body": response.body};
      } else {
        return {"error": "Failed to update loan: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }
   /// Delete loan
  static Future<Map<String, dynamic>> deleteLoan(String userId, String loanId) async {
    try {
      final token = await _storage.read(key: "jwt");
    if (token == null) {
      return {"error": "No token found", "body": null};
    }
      final response = await http.delete(
        Uri.parse("$_baseUrl/api/v1/loans/$userId/$loanId"),
        headers: {"Authorization": "Bearer $token",
          "Content-Type": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {"body": "Loan deleted"};
      } else {
        return {"error": "Failed to delete loan: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
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
      Uri.parse("$_baseUrl/api/v1/user/create"),
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
