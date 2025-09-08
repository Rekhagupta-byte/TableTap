import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'email_input_screen.dart';
import '../owner/owner_home_screen.dart';
import '../staff/waiter/waiter_home_screen.dart';
import '../staff/chef/chef_order_screen.dart';
import '../staff/manager/manager_dashboard_screen.dart';

import '../../utils/api_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordVisible = false;

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    final url = Uri.parse(api('/login'));

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['user'];
        final role = user['role'].toString().toLowerCase();
        int isActivated = user['is_activated'] != null
            ? int.parse(user['is_activated'].toString())
            : 0;

        // Save login info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', role);
        await prefs.setString('staffInfo', jsonEncode({
          ...user,
          'role': role,
          'is_activated': isActivated,
        }));

        // Navigate based on role
        if (role == 'owner') {
          await prefs.setString('owner_name', user['name'] ?? 'Owner');
          await prefs.setString('owner_email', user['email'] ?? email);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
          );
        } else if (role == 'waiter') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => WaiterHomeScreen(staff: user)),
          );
        } else if (role == 'chef') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ChefOrderScreen(staff: user)),
          );
        } else if (role == 'manager') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ManagerDashboardScreen(staff: user)),
          );
        } else {
          // fallback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown role")),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'TableTap',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Login to your account',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
                decoration: inputDecoration('Email', Icons.email),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: !passwordVisible,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter password' : null,
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EmailInputScreen()),
                  ),
                  child: Text(
                    "Don't have an account? Sign up",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
