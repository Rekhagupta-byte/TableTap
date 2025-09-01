import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/screens/auth/login_screen.dart';
import 'package:tabletap_frontend/screens/owner/manage_staff/manage_staff_screen.dart';
import 'package:tabletap_frontend/screens/owner/qrcode/generate_qr_screen.dart';
import 'manage_menu_screen.dart';
import 'manage_orders_screen.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  // ✅ Logout Function
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved login info

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Rekha Kumari'),
              accountEmail: const Text('kumarirekha6465@gmail.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.deepPurple, size: 36),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Manage Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageMenuScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Manage Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Manage Staff'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageStaffScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Manage QR'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GenerateQRScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context), // ✅ Fixed
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Owner Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text('Owner',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        )),
                  ],
                ),
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                )
              ],
            ),

            const SizedBox(height: 30),

            // 💡 Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.restaurant_menu,
                    label: 'Manage Menu',
                    color: Colors.purpleAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageMenuScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.receipt_long,
                    label: 'View Orders',
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageOrdersScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.group,
                    label: 'Manage Staff',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageStaffScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.qr_code_2,
                    label: 'Manage QR',
                    color: Colors.indigoAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GenerateQRScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.blueAccent,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("To Do")));
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    color: Colors.redAccent,
                    onTap: () => _logout(context), // ✅ Fixed
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 Reusable Card Widget
  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500, color: color),
            )
          ],
        ),
      ),
    );
  }
}
