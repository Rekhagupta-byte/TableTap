import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your actual IP if testing on real phone
  static const String baseUrl = 'http://192.168.0.244:5000';

  static Future<List<dynamic>> fetchMenuItems() async {
    final response = await http.get(Uri.parse('$baseUrl/menu'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load menu');
    }
  }
}
