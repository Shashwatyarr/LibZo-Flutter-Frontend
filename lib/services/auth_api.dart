import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthApi {
  static const String baseUrl = "http://10.0.2.2:5000/api/auth";

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String fullname,
    required String email,
    required String password,
  }) async {
    print("signup me aya");
    final response = await http.post(Uri.parse("$baseUrl/signup"),

        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "username": username,
          "fullName": fullname,
          "email": email,
          "password": password,
        })

    );
    print("signup me aya");
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print("sup me aya");
    final headers=await _getAuthHeaders();
    final response = await http.post(Uri.parse("$baseUrl/login"),
        headers: headers,
        body: json.encode({
          "email": email,
          "password": password,
        })
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    return _handleResponse(response);
  }
  static Future<void> resendOtp(String email) async {
    await http.post(
      Uri.parse("$baseUrl/send-otp"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({"email": email}),
    );
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Map<String,dynamic> _handleResponse(http.Response response){
    final data=jsonDecode(response.body);

    if(response.statusCode>=200 && response.statusCode<300){
      return data;
    }
    else{
      throw data['message']??"Something wnt wrong";
    }
  }
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }



}


