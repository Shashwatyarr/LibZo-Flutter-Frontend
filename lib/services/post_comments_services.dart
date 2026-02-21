import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostCommentsServices {
  static const baseUrl = "http://10.0.2.2:5000";
  // static const baseUrl="https://libzo-backend.onrender.com";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future createComments(String postId,String text) async{
    final token=await getToken();
    
    final res=await http.post(Uri.parse('$baseUrl/comments/add'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "postId": postId,
        "text": text,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getComments(String postId)async{
    final token=await getToken();

    final res=await http.get(Uri.parse
      ("$baseUrl/comments/$postId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    return jsonDecode(res.body);
  }
}