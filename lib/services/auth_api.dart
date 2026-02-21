import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {

  static const String baseUrl =
      "http://10.0.2.2:5000/api/auth";
  //
  // static const String baseUrl =
  //     "https://libzo-backend.onrender.com/api/auth";


  /* ===================== SIGNUP ===================== */
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String fullname,
    required String email,
    required String password,
    required String telegramUsername,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/signup"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "username": username,
        "fullName": fullname,
        "email": email,
        "password": password,

        // 👉 NEW FIELD
        "telegramUsername": telegramUsername,
      }),
    );

    return _handleResponse(response);
  }


  /* ===================== LOGIN STEP-1 ===================== */
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return _handleResponse(response);
  }


  /* ===================== TELEGRAM STATUS ===================== */
  static Future<bool> checkTelegramLinked(String username) async {

    final response = await http.get(
      Uri.parse("$baseUrl/telegram-status/$username"),
    );

    final data = _handleResponse(response);

    return data["linked"] ?? false;
  }


  /* ===================== REQUEST OTP ===================== */
  static Future<Map<String, dynamic>> requestOtp({
    required String username,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/request-otp"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "username": username,
      }),
    );

    return _handleResponse(response);
  }


  /* ===================== VERIFY OTP ===================== */
  static Future<Map<String, dynamic>> verifyOtp({
    required String username,
    required String otp,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/verify-otp"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "username": username,
        "otp": otp,
      }),
    );

    final data = _handleResponse(response);

    // 🔥 SAVE TOKEN + USER ID
    if (data["token"] != null && data["user"] != null) {
      await saveToken(data["token"]);
      await saveUserId(data["user"]["_id"]);
      await saveUsername(username);
    }
    await saveUsername(username);
    return data;
  }


  /* ===================== TOKEN STORAGE ===================== */

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }


  /* ===================== LOGOUT ===================== */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  /* ===================== AUTH HEADERS ===================== */
  static Future<Map<String, String>> getAuthHeaders() async {

    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    return token != null;
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  /* ===================== RESPONSE HANDLER ===================== */
  static Map<String, dynamic> _handleResponse(http.Response response) {

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      return data;

    } else {
      throw Exception(
          data["message"] ?? "Something went wrong"
      );
    }
  }


  // ============================================================
  //                    FOLLOW SYSTEM
  // ============================================================

  /* ===================== FOLLOW USER ===================== */
  static Future<bool> followUser(String userId) async {

    final headers = await getAuthHeaders();

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/follow/$userId"),
      headers: headers,
    );

    final data = _handleResponse(response);

    return data["success"] == true;
  }


  /* ===================== UNFOLLOW USER ===================== */
  static Future<bool> unfollowUser(String userId) async {

    final headers = await getAuthHeaders();

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/unfollow/$userId"),
      headers: headers,
    );

    final data = _handleResponse(response);

    return data["success"] == true;
  }


  /* ===================== GET FOLLOWERS ===================== */
  static Future<List<dynamic>> getFollowers(String userId) async {

    final response = await http.get(
      Uri.parse("http://10.0.2.2:5000/followers/$userId"),
    );

    final data = _handleResponse(response);

    return data["followers"] ?? [];
  }


  /* ===================== GET FOLLOWING ===================== */
  static Future<List<dynamic>> getFollowing(String userId) async {

    final response = await http.get(
      Uri.parse("http://10.0.2.2:5000/following/$userId"),
    );

    final data = _handleResponse(response);

    return data["following"] ?? [];
  }


  /* ===================== CHECK IS FOLLOWING ===================== */
  static Future<bool> isFollowing(String targetUserId) async {

    final myId = await getUserId();
    if (myId == null) return false;

    final followingList = await getFollowing(myId);

    return followingList.any(
          (user) => user["_id"] == targetUserId,
    );
  }

}
