import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditStaffScreen extends StatefulWidget {
  final Map<String, dynamic> staff;
  const EditStaffScreen({super.key, required this.staff});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late String role;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.staff['name']);
    emailController = TextEditingController(text: widget.staff['email']);
    phoneController = TextEditingController(text: widget.staff['phone'] ?? '');
    role = widget.staff['role'];
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    setState(() => isSubmitting = true);

    try {
      final response = await http.put(
        Uri.parse("http://192.168.0.244:5000/staff/${widget.staff['id']}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "role": role,
        }),
      );

      setState(() => isSubmitting = false);

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Staff updated successfully")),
          );
        }
      } else {
        String message = "Error";
        try {
          message = jsonDecode(response.body)['message'] ?? "Error";
        } catch (_) {}
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ $message")),
          );
        }
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Network error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Staff", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Full Name",
                  controller: nameController, validator: true),
              _buildTextField("Email",
                  controller: emailController,
                  keyboard: TextInputType.emailAddress,
                  validator: true),
              _buildTextField("Phone (optional)",
                  controller: phoneController, keyboard: TextInputType.phone),
              const SizedBox(height: 10),
              _buildDropdown("Role", ["Waiter", "Chef", "Manager"],
                  value: role, onChanged: (val) => setState(() => role = val!)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSubmitting ? null : _updateStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Staff",
                        style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller,
      TextInputType keyboard = TextInputType.text,
      bool validator = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator
            ? (value) =>
                (value == null || value.isEmpty) ? "$label required" : null
            : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options,
      {required String value, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
