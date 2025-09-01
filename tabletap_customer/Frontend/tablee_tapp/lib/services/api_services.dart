import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class ApiService {
  // ✅ Base URL - Change here only when needed
  static const String baseUrl = 'http://192.168.0.244:5000';

  /// Fetch menu from backend
  static Future<List<MenuItem>> fetchMenu({String? menuUrl}) async {
    try {
      // ✅ Ensure menuUrl is used if provided, else default to /menu
      final Uri url = menuUrl != null && menuUrl.isNotEmpty
          ? Uri.parse(menuUrl)
          : Uri.parse('$baseUrl/menu');

      print("📡 Fetching menu from: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print("✅ Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          // ✅ Ensure it's a list
          if (data is List) {
            return data.map((item) => MenuItem.fromJson(item)).toList();
          } else {
            throw Exception('Unexpected response format: Expected a list');
          }
        } catch (jsonError) {
          throw Exception("Invalid JSON format: $jsonError");
        }
      } else {
        throw Exception(
            'Failed to load menu (Code: ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw Exception("Network error: $e");
    } on Exception catch (e) {
      throw Exception("Error fetching menu: $e");
    }
  }
}
