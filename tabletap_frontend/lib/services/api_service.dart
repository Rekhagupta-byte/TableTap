import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tabletap_frontend/constants.dart'; // import your constants

class ApiService {
  // Use baseUrl from constants
  static String get baseUrl => ApiConstants.baseUrl;

  static Future<List<dynamic>> fetchMenuItems() async {
    final response = await http.get(Uri.parse('$baseUrl/menu'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load menu');
    }
  }
}
