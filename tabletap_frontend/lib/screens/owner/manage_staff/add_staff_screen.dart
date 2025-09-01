import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String role = 'Waiter';
  String phone = '';

  bool isSubmitting = false;

  Future<void> _submitStaff() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.244:5000/invite"), // backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "role": role,
          "phone": phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Invite sent to $email")),
        );
        Navigator.pop(context, true);
      } else {
        final message = data['message'] ?? "Error sending invite";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $message")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Network error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Staff", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                "Full Name",
                onSaved: (val) => name = val!,
                validator: true,
              ),
              _buildTextField(
                "Email",
                keyboard: TextInputType.emailAddress,
                onSaved: (val) => email = val!,
                validator: true,
              ),
              _buildTextField(
                "Phone (optional)",
                keyboard: TextInputType.phone,
                onSaved: (val) => phone = val ?? '',
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                "Role",
                ["Waiter", "Chef", "Manager"],
                (val) => setState(() => role = val!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send Invite",
                        style: TextStyle(color: Colors.white),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextInputType keyboard = TextInputType.text,
    required Function(String?) onSaved,
    bool validator = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator
            ? (value) =>
                (value == null || value.isEmpty) ? "$label required" : null
            : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: role, // updated to use the selected role
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
