import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  static const String baseUrl =
      "http://10.0.2.2:5000/library";
  // static const String baseUrl =
  //     "https://libzo-backend.onrender.com/library";
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  // ===== ALL BOOKS =====
  static Future<Map<String, dynamic>> getAllBooks(int page) async {
    final url = Uri.parse("$baseUrl/all?page=$page");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load books");
    }
  }

  // ===== TRENDING =====
  static Future<Map<String, dynamic>> getTrending(int page) async {
    final url = Uri.parse("$baseUrl/trending?page=$page");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load trending");
    }
  }

  // ===== CATEGORIES =====
  static Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse("$baseUrl/categories");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // ===== BY CATEGORY =====
  static Future<Map<String, dynamic>> getByCategory(
      String category, int page) async {

    final encoded = Uri.encodeComponent(category);

    final url =
    Uri.parse("$baseUrl/category/$encoded?page=$page");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load category");
    }
  }

  // ===== SINGLE BOOK =====
  static Future<Map<String, dynamic>> getBook(String id) async {
    final url = Uri.parse("$baseUrl/book/$id");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load book");
    }
  }

  // ===== SEARCH =====
  static Future<Map<String, dynamic>> search(String query) async {
    final encoded = Uri.encodeComponent(query);

    final url = Uri.parse("$baseUrl/search?q=$encoded");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Search failed");
    }
  }
  static Future<void> increasePopularity(String id) async {
    final url = Uri.parse("$baseUrl/popular/$id");

    await http.post(url);
  }
  // ===== GET REVIEWS WITH PAGINATION =====
  static Future<Map<String, dynamic>> getReviews(
      String bookId, int page) async {
    final token = await getToken();
    final url = Uri.parse(
        "http://10.0.2.2:5000/api/review/$bookId?page=$page");

    final res = await http.get(url,headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },);

    return jsonDecode(res.body);
  }


// ===== TOGGLE LIKE =====
  static Future<Map<String, dynamic>> toggleLike(
      String reviewId) async {
    final token = await getToken();
    final url = Uri.parse(
        "http://10.0.2.2:5000/api/review/like/$reviewId");

    final res = await http.post(url,headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },);

    return jsonDecode(res.body);
  }


// ===== ADD REVIEW =====
  static Future<Map<String, dynamic>> addReview({
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    final token = await getToken();
    final url = Uri.parse("http://10.0.2.2:5000/api/review");

    final res = await http.post(
      url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      body: jsonEncode({
        "bookId": bookId,
        "rating": rating,
        "comment": comment,
      }),
    );
    print("DATA Send");
    return jsonDecode(res.body);
  }

}


