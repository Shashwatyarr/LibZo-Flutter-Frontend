import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
  static Future<void> deletePost({
    required String clubId,
    required String postId,
  }) async {

    final headers = await getHeaders();

    final res = await http.delete(
      Uri.parse("$baseUrl/$clubId/posts/$postId"),
      headers: headers,
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Delete failed");
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

    final token = await getToken();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/$clubId/posts"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["content"] = content;
    request.fields["type"] = type;

    if (imageFile != null) {

      final mime = lookupMimeType(imageFile.path) ?? "image/jpeg";

      request.files.add(
        await http.MultipartFile.fromPath(
          "cover",                         // ✅ MATCH WITH BACKEND
          imageFile.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }


  // ================= GET POSTS =================

  static Future<List<dynamic>> getPosts(String clubId) async {
    try {
      final headers = await getHeaders();

      final url = "$baseUrl/$clubId/posts";

      print("🌐 GET POSTS URL: $url");

      final res = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print("📡 STATUS: ${res.statusCode}");
      print("📦 RAW BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {

        // 🔥 MAIN SAFE HANDLING
        if (data == null) return [];

        final posts = data["posts"];

        if (posts == null) return [];

        return List<dynamic>.from(posts);

      } else {
        throw Exception(data["message"] ?? "Failed to load posts");
      }

    } catch (e) {
      print("❌ Get Posts Error: $e");
      return [];   // ← crash se better empty list
    }
  }


  // ================= UPVOTE =================

  static Future<Map<String, dynamic>> toggleUpvote({
    required String clubId,
    required String postId,
  }) async {
    try {
      final headers = await getHeaders();

      final res = await http.patch(
        Uri.parse("$baseUrl/$clubId/posts/$postId/upvote"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Upvote failed");
      }

    } catch (e) {
      throw Exception("Upvote Error: $e");
    }
  }

// ================= DOWNVOTE =================

  static Future<Map<String, dynamic>> toggleDownvote({
    required String clubId,
    required String postId,
  }) async {
    try {
      final headers = await getHeaders();

      final res = await http.patch(
        Uri.parse("$baseUrl/$clubId/posts/$postId/downvote"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Downvote failed");
      }

    } catch (e) {
      throw Exception("Downvote Error: $e");
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
  // ================= HANDLE REQUEST (APPROVE / REJECT) =================

  static Future<String> handleRequest({
    required String clubId,
    required String requestId,
    required String action,   // "approve" or "reject"
  }) async {

    try {
      final headers = await getHeaders();

      final res = await http.patch(
        Uri.parse("$baseUrl/$clubId/request/$requestId"),

        headers: headers,

        body: jsonEncode({
          "action": action,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data["message"];
      } else {
        throw Exception(data["message"] ?? "Action failed");
      }

    } catch (e) {
      throw Exception("Handle Request Error: $e");
    }
  }

}
