import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabletap_frontend/utils/api_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Icon(Icons.restaurant_menu,
                    size: 100, color: Colors.white.withOpacity(0.9)),
                const SizedBox(height: 20),
                Text(
                  "Welcome to TableTap",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Start your dining experience by scanning the QR code on your table.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons section
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuButton(
                        context,
                        icon: Icons.qr_code_scanner,
                        label: "Scan QR",
                        onTap: () {
                          Navigator.pushNamed(context, '/scan-qr');
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: Icons.menu_book,
                        label: "View Menu",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/menu',
                            arguments: {
                              'menuUrl': api('/menu'),

                            },
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: Icons.receipt_long,
                        label: "Your Order",
                        onTap: () {
                          Navigator.pushNamed(context, '/last-order');
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: Icons.track_changes,
                        label: "View Status",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/order-status',
                            arguments: {'orderId': 123}, // placeholder
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Powered by TableTap 🍽️",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 26),
        label: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
      ),
    );
  }
}
