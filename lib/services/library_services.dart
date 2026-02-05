import 'dart:convert';
import 'package:http/http.dart' as http;

class LibraryService {
  static const String baseUrl =
      "http://10.0.2.2:5000/library";

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
}
