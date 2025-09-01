import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tabletap_frontend/screens/auth/signup_from_screen.dart';
import 'dart:convert';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final otpController = TextEditingController();
  bool isResendAllowed = true;
  bool isVerifying = false;
  int resendCooldown = 60;

  void verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    setState(() => isVerifying = true);

    final url = Uri.parse("http://192.168.0.244:5000/verify-otp");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'otp': otpController.text.trim(),
      }),
    );

    setState(() => isVerifying = false);

    final data = jsonDecode(response.body);
    if (data['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignupFormScreen(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Invalid OTP')),
      );
    }
  }

  void resendOtp() async {
    if (!isResendAllowed) return;
    setState(() => isResendAllowed = false);

    final url = Uri.parse("http://192.168.0.244:5000/send-otp");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );

    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'OTP resent')),
    );

    Future.delayed(Duration(seconds: resendCooldown), () {
      setState(() => isResendAllowed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("OTP Verification"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_open_rounded, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                "OTP sent to",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              Text(
                widget.email,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter 6-digit OTP',
                  counterText: '',
                  prefixIcon: const Icon(Icons.numbers),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isVerifying
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "Verify OTP",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: isResendAllowed ? resendOtp : null,
                child: Text(
                  isResendAllowed ? "Resend OTP" : "Please wait...",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isResendAllowed ? Colors.deepPurple : Colors.grey,
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
