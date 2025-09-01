import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class DatabaseService {
  static const String baseUrl =
      'http://192.168.0.244:5000'; // Replace with your Flask IP

  // 🔹 Get all menu items
  static Future<List<MenuItem>> getMenuItems() async {
    final response = await http.get(Uri.parse('$baseUrl/menu'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MenuItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load menu');
    }
  }

  // 🔹 Add menu item
  static Future<void> addMenuItem(MenuItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add menu item');
    }
  }

  // 🔹 Update menu item
  static Future<void> updateMenuItem(MenuItem item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/menu/${item.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  // 🔹 Delete menu item
  static Future<void> deleteMenuItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/menu/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }
}
