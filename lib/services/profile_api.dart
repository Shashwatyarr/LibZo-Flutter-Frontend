import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_api.dart';

class ProfileApi {
  static const String baseUrl =
      "http://10.0.2.2:5000/api/profile";
  // static const String baseUrl =
  //     "https://libzo-backend.onrender.com/api/profile";

  /* ===================== GET PROFILE ===================== */
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    return _handleResponse(response);
  }

  /* ===================== UPDATE PROFILE ===================== */
  static Future<void> updateProfile(
      Map<String, dynamic> updates,
      ) async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.put(
      Uri.parse("$baseUrl/update"),
      headers: headers,
      body: jsonEncode(updates),
    );

    _handleResponse(response);
  }

  /* ===================== PROFILE COMPLETION ===================== */
  static Future<int> getProfileCompletion() async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/completion"),
      headers: headers,
    );

    final data = _handleResponse(response);
    return data["completion"] ?? 0;
  }

  /* ===================== USER LIBRARY ===================== */
  static Future<List<dynamic>> getUserLibrary() async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/library"),
      headers: headers,
    );

    final data = _handleResponse(response);
    return data["data"] ?? [];
  }

  /* ===================== UPLOAD PROFILE PHOTO ===================== */
  static Future<String> uploadProfilePhoto(File imageFile) async {
    final token = await AuthApi.getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-photo"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "profileImage",
        imageFile.path,
        contentType: MediaType("image", "jpeg"),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data["profileImage"];
    } else {
      throw Exception(data["message"] ?? "Image upload failed");
    }
  }

  /* ===================== RESPONSE HANDLER ===================== */
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Something went wrong");
    }
  }
}
