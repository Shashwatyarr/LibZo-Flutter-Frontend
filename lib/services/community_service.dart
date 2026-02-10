import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityService {

  static const String baseUrl = "http://10.0.2.2:5000/api/clubs";
  static String getCoverUrl(String fileId) {
    return "$baseUrl/cover/$fileId";
  }

  // ================= TOKEN =================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // ================= CREATE CLUB =================

  static Future<Map<String, dynamic>> createClub({
    required String name,
    required String description,
    required List<String> genre,
    required String type,
    required String? imagePath,   // 👈 NEW
  }) async {
    try {
      final token = await getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(baseUrl),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token"
      });

      // Text fields
      request.fields["name"] = name;
      request.fields["description"] = description;
      request.fields["type"] = type;

      // Genre array as JSON string
      request.fields["genre"] = jsonEncode(genre);

      // ───── COVER IMAGE ─────
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "cover",
            imagePath,
          ),
        );
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to create club");
      }

    } catch (e) {
      throw Exception("Create Club Error: $e");
    }
  }


  // ================= GET CLUBS =================

  static Future<Map<String, dynamic>> getClubs() async {
    try {
      final headers = await getHeaders();

      final res = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to load clubs");
      }

    } catch (e) {
      throw Exception("Get Clubs Error: $e");
    }
  }

  // ================= JOIN CLUB =================

  static Future<String> joinClub(String clubId) async {
    try {
      final headers = await getHeaders();

      final res = await http.post(
        Uri.parse("$baseUrl/$clubId/join"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data["message"];
      } else {
        throw Exception(data["message"] ?? "Join failed");
      }

    } catch (e) {
      throw Exception("Join Club Error: $e");
    }
  }

  // ================= GET SINGLE CLUB =================

  static Future<Map<String, dynamic>> getSingleClub(String clubId) async {
    try {
      final headers = await getHeaders();

      final res = await http.get(
        Uri.parse("$baseUrl/$clubId"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to load club");
      }

    } catch (e) {
      throw Exception("Get Club Error: $e");
    }
  }

  // ================= CREATE POST =================

  static Future<Map<String, dynamic>> createClubPostWithImage({
    required String clubId,
    required String content,
    required String type,
    File? imageFile,
  }) async {

    try {
      final token = await getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/$clubId/posts"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["content"] = content;
      request.fields["type"] = type;

      // ───── IMAGE ATTACH ─────
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images",
            imageFile.path,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data["message"] ?? "Post failed");

    } catch (e) {
      throw Exception("Create Post Error: $e");
    }
  }


  // ================= GET POSTS =================

  static Future<List<dynamic>> getPosts(String clubId) async {
    try {
      final headers = await getHeaders();

      final res = await http.get(
        Uri.parse("$baseUrl/$clubId/posts"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception("Failed to load posts");
      }

    } catch (e) {
      throw Exception("Get Posts Error: $e");
    }
  }

  // ================= ADD COMMENT =================

  static Future<Map<String, dynamic>> addComment({
    required String clubId,
    required String postId,
    required String text,
  }) async {
    try {
      final headers = await getHeaders();

      final res = await http.post(
        Uri.parse("$baseUrl/$clubId/posts/$postId/comments"),
        headers: headers,
        body: jsonEncode({
          "text": text,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Comment failed");
      }

    } catch (e) {
      throw Exception("Add Comment Error: $e");
    }
  }

  // ================= GET COMMENTS =================

  static Future<List<dynamic>> getComments({
    required String clubId,
    required String postId,
  }) async {
    try {
      final headers = await getHeaders();

      final res = await http.get(
        Uri.parse("$baseUrl/$clubId/posts/$postId/comments"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception("Failed to load comments");
      }

    } catch (e) {
      throw Exception("Get Comments Error: $e");
    }
  }
  // ================= GET JOIN REQUESTS =================

  static Future<List<dynamic>> getRequests(String clubId) async {
    try {
      final headers = await getHeaders();

      final res = await http.get(
        Uri.parse("$baseUrl/$clubId/requests"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data["requests"];
      } else {
        throw Exception(data["message"] ?? "Failed to load requests");
      }

    } catch (e) {
      throw Exception("Get Requests Error: $e");
    }
  }

}
