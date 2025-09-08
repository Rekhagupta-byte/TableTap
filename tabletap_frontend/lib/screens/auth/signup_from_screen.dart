import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/utils/api_helper.dart';

import '../customer/customer_screen/home_screen.dart';
import '../owner/owner_home_screen.dart'; // Create this if you haven't
// import '../home/home_screen.dart'; // Not needed now unless you want a shared home

class SignupFormScreen extends StatefulWidget {
  final String email;
  const SignupFormScreen({super.key, required this.email});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final secretCodeController = TextEditingController();

  String selectedRole = 'user';

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false;

  Future<void> signup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final url = Uri.parse(api('/signup'));

    final name = nameController.text.trim();
    final password = passwordController.text;
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': widget.email,
          'password': password,
          'role': selectedRole,
          'secret_code':
              selectedRole == 'owner' ? secretCodeController.text.trim() : '',
        }),
      );

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // ✅ Save role in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', selectedRole);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        // ✅ Navigate based on role
        if (selectedRole == 'owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Signup failed')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error, please try again.")),
      );
    }
  }

  InputDecoration inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Complete Signup"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.person_add_alt_1_rounded,
                  size: 60, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: nameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
                decoration: inputDecoration('Full Name', Icons.person),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: widget.email,
                enabled: false,
                decoration: inputDecoration('Verified Email', Icons.email),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration:
                    inputDecoration("Select Role", Icons.admin_panel_settings),
                items: ['owner', 'user']
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              if (selectedRole == 'owner') ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: secretCodeController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Secret code is required for owner'
                      : null,
                  decoration: inputDecoration('Secret Code', Icons.vpn_key),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: !passwordVisible,
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                decoration: inputDecoration(
                  'Password',
                  Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => passwordVisible = !passwordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !confirmPasswordVisible,
                validator: (value) => value != passwordController.text
                    ? 'Passwords do not match'
                    : null,
                decoration: inputDecoration(
                  'Confirm Password',
                  Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => confirmPasswordVisible = !confirmPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => signup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
