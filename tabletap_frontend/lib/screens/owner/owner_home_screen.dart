import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/screens/auth/login_screen.dart';
import 'package:tabletap_frontend/screens/owner/manage_staff/manage_staff_screen.dart';
import 'package:tabletap_frontend/screens/owner/qrcode/generate_qr_screen.dart';
import 'manage_menu_screen.dart';
import 'manage_orders_screen.dart';
import 'owner_profile_screen.dart'; // <-- import your profile screen

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  String ownerName = '';
  String ownerEmail = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerInfo();
  }

  Future<void> _loadOwnerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ownerName = prefs.getString('owner_name') ?? 'Owner';
      ownerEmail = prefs.getString('owner_email') ?? 'owner@example.com';
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Navigate to Profile Screen
  void _goToProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const OwnerProfileScreen(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(ownerName),
              accountEmail: Text(ownerEmail),
              currentAccountPicture: GestureDetector(
                onTap: _goToProfile,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurple, size: 36),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _goToProfile();
              },
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
              onTap: () async => await _logout(context),
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
      body: RefreshIndicator(
        onRefresh: _loadOwnerInfo,
        child: Padding(
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
                      Text(ownerName,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          )),
                      
                    ],
                  ),
                  GestureDetector(
                    onTap: _goToProfile, // <-- tap on profile avatar
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepPurple,
                      child:
                          const Icon(Icons.person, size: 30, color: Colors.white),
                    ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("To Do")));
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.logout,
                      label: 'Logout',
                      color: Colors.redAccent,
                      onTap: () async => await _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
