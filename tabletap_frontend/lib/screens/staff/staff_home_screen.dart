import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabletap_frontend/screens/staff/staff_order_screen.dart';
import 'staff_profile_screen.dart';
import 'staff_change_password_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final Map<String, dynamic> staff;
  const StaffHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(staff['name'], style: GoogleFonts.poppins()),
              accountEmail: Text(staff['email'], style: GoogleFonts.poppins()),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  staff['name'][0].toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 24, color: Colors.deepPurple),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            drawerItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StaffProfileScreen(staff: staff)),
                );
              },
            ),
            drawerItem(
              context,
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StaffChangePasswordScreen(email: staff['email'])),
                );
              },
            ),
            drawerItem(
              context,
              icon: Icons.receipt_long,
              title: 'Orders',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StaffOrderScreen(staff: staff)),
                );
              },
            ),
            drawerItem(
              context,
              icon: Icons.feedback,
              title: 'Feedback',
              onTap: () {
                Navigator.pop(context);
                // Navigate to Feedback Screen if implemented
              },
            ),
            const Divider(),
            drawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${staff['name']}!',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  dashboardCard(
                    context,
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StaffChangePasswordScreen(email: staff['email'])),
                    ),
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StaffOrderScreen(staff: staff)),
                    ),
                  ),
                  dashboardCard(
                    context,
                    icon: Icons.feedback,
                    title: 'Feedback',
                    onTap: () {
                      // Optional feedback screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap,
    );
  }
}
