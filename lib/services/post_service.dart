import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const baseUrl = "http://10.0.2.2:5000";
  // static const baseUrl="https://libzo-backend.onrender.com";

  // ================= TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ================= GET FEED =================
  static Future<List> getFeed() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/posts/feed"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is Map && data["posts"] != null) {
        return data["posts"];
      }

      if (data is List) {
        return data;
      }

      return [];
    } else {
      return [];
    }
  }

  // ================= CREATE POST =================
  static Future<void> createPost({
    required String text,
    required List<File> images,
  }) async {

    if (text.trim().isEmpty) {
      throw Exception("Text is mandatory");
    }

    if (images.length > 4) {
      throw Exception("You can upload maximum 4 images");
    }

    for (var img in images) {
      final sizeInMB = img.lengthSync() / (1024 * 1024);
      if (sizeInMB > 5) {
        throw Exception("Each image must be ≤ 5MB");
      }
    }

    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/posts/create"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.fields["text"] = text;

      for (var img in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images",
            img.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 201) {
        throw Exception(
          jsonDecode(responseBody)["message"] ?? "Post failed",
        );
      }

    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  // ================= 🔥 TOGGLE LIKE (REAL) =================
  static Future<bool> toggleLike(String postId) async {

    final token = await getToken();

    final res = await http.post(
      Uri.parse("$baseUrl/posts/like/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // 200 = toggled successfully
    return res.statusCode == 200;
  }

}
