import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:5000";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<List> getFeed() async {
    final res = await http.get(
      Uri.parse("$baseUrl/posts/feed"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return [];
    }
  }

  static Future<bool> createPost(String text) async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse("$baseUrl/posts/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "text": text,
        "imageUrl": "",
      }),
    );
    print(res.statusCode);
    print(res.body);

    return res.statusCode == 201;
  }

  static Future likePost(String postId) async {
    print("like");
    final token=await getToken();
    await http.post(
      Uri.parse("$baseUrl/post/like/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
