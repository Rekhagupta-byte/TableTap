import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tabletap_frontend/utils/api_helper.dart';
import 'dart:convert';

import 'add_menu_item_screen.dart';
import 'edit_menu_item_screen.dart';

class ManageMenuScreen extends StatefulWidget {
  const ManageMenuScreen({super.key});

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  List<dynamic> menuItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  /// Fetch all menu items
  Future<void> fetchMenuItems() async {
    try {
      final url = Uri.parse(api('/menu')); // ✅ use api() helper
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          menuItems = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar("Failed to load menu");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error: $e");
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(int itemId) async {
    try {
      final url = Uri.parse(api('/menu/$itemId')); // ✅ use api() helper
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          menuItems.removeWhere((item) => item['id'] == itemId);
        });
        _showSnackBar("Item deleted");
      } else {
        _showSnackBar("Failed to delete item");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  /// Show confirmation before delete
  void _confirmDelete(BuildContext context, int itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop();
              deleteMenuItem(itemId);
            },
          ),
        ],
      ),
    );
  }

  /// Build menu card UI
  Widget buildMenuCard(dynamic item) {
    String? imageUrl = item['image_url'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        imageUrl = api(imageUrl); // ✅ convert relative paths using api()
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),

            const SizedBox(width: 16),

            // details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹ ${item['price']?.toString() ?? '0'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditMenuItemScreen(menuItem: item),
                            ),
                          );
                          if (updated == true) {
                            fetchMenuItems();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, item['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Menu", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuItems.isEmpty
              ? const Center(child: Text("No menu items found"))
              : RefreshIndicator(
                  onRefresh: fetchMenuItems,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) =>
                        buildMenuCard(menuItems[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMenuItemScreen()),
          );
          if (result == true) {
            fetchMenuItems();
          }
        },
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
