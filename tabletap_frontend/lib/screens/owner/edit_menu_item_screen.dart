import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tabletap_frontend/utils/api_helper.dart';

class EditMenuItemScreen extends StatefulWidget {
  final dynamic menuItem;

  const EditMenuItemScreen({super.key, required this.menuItem});

  @override
  State<EditMenuItemScreen> createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController categoryController;
  late TextEditingController imageUrlController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.menuItem['name']);
    priceController =
        TextEditingController(text: widget.menuItem['price'].toString());
    categoryController =
        TextEditingController(text: widget.menuItem['category']);
    imageUrlController =
        TextEditingController(text: widget.menuItem['image_url'] ?? '');
  }

  Future<void> updateMenuItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

   final url = Uri.parse(api('/menu/${widget.menuItem['id']}'));


    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'category': categoryController.text.trim(),
        'image_url': imageUrlController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Widget inputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: optional
          ? null
          : (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.deepPurple),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text("Edit Menu Item", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                inputField("Item Name", Icons.fastfood, nameController),
                const SizedBox(height: 16),
                inputField("Price", Icons.currency_rupee, priceController,
                    isNumber: true),
                const SizedBox(height: 16),
                inputField("Category", Icons.category, categoryController),
                const SizedBox(height: 16),
                inputField("Image URL", Icons.image, imageUrlController,
                    optional: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : updateMenuItem,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isLoading ? "Updating..." : "Update Item",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
