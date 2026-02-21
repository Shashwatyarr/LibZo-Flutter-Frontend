import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_api.dart';

class ProfileApi {
  static const String apiRoot = "http://10.0.2.2:5000/api/profile";
  // static const String apiRoot =
  //     "https://libzo-backend.onrender.com/api/profile";

  // ================= GET MY PROFILE =================
  static Future<Map<String, dynamic>> getMyProfile(String? userId) async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.get(
      Uri.parse("$apiRoot/"),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // ================= UPDATE PROFILE =================
  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final headers = await AuthApi.getAuthHeaders();

    final response = await http.put(
      Uri.parse("$apiRoot/update"),
      headers: headers,
      body: jsonEncode(updates),
    );

    _handleResponse(response);
  }

  // ================= UPLOAD PHOTO =================
  static Future<String> uploadProfilePhoto(File imageFile) async {

    final token = await AuthApi.getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$apiRoot/upload-photo"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "profileImage",
        imageFile.path,
        contentType: MediaType("image", "jpeg"),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data["profileImage"];
    } else {
      throw Exception(data["message"] ?? "Image upload failed");
    }
  }

  // ================= PROFILE COMPLETION =================
  static Future<int> getProfileCompletion() async {

    final headers = await AuthApi.getAuthHeaders();

    final response = await http.get(
      Uri.parse("$apiRoot/completion"),
      headers: headers,
    );

    final data = _handleResponse(response);

    return data["completion"] ?? 0;
  }

  // =====================================================
  //               🔥 PUBLIC PROFILE
  // =====================================================

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {

    final headers = await AuthApi.getAuthHeaders();

    final url = "$apiRoot/$userId";   // ✅ FIXED

    print("==== PROFILE CALL ====");
    print("URL: $url");
    print("HEADERS: $headers");

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = _handleResponse(response);

    if (data is Map && data["user"] != null) {
      return data["user"];
    }

    return data;
  }

  // =====================================================
  //               USER POSTS
  // =====================================================

  static Future<List<dynamic>> getUserPosts(String userId) async {

    final headers = await AuthApi.getAuthHeaders();

    final url = "$apiRoot/posts/$userId";

    print("POST URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    final data = _handleResponse(response);

    if (data is List) return data;

    if (data is Map && data.containsKey("posts")) {
      return data["posts"];
    }

    return [];
  }


  // =====================================================
  //              RESPONSE HANDLER
  // =====================================================

  static dynamic _handleResponse(http.Response response) {

    if (response.body.trim().startsWith("<!DOCTYPE")) {
      throw Exception(
          "Server returned HTML instead of JSON – route mismatch"
      );
    }

    if (response.body.isEmpty) return null;

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data["message"] ??
            "Something went wrong (Status: ${response.statusCode})",
      );
    }
  }
}
