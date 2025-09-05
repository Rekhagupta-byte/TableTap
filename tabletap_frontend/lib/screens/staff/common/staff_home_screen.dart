import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabletap_frontend/screens/staff/waiter/waiter_order_screen.dart';
import 'package:tabletap_frontend/screens/staff/chef/chef_order_screen.dart';
import 'package:tabletap_frontend/screens/staff/manager/manager_dashboard_screen.dart';
import 'staff_profile_screen.dart';
import '../../auth/staff_change_password_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final Map<String, dynamic> staff;
  const StaffHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    // Normalize role
    String role = (staff['role'] ?? '').toString().toLowerCase();
    String roleName = role.isNotEmpty
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : 'Staff';

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleName Dashboard', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: _buildDrawer(context, role, roleName),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${staff['name']}!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildDashboard(context, role)),
          ],
        ),
      ),
    );
  }

  /// Drawer with common + role-based items
  Widget _buildDrawer(BuildContext context, String role, String roleName) {
    return Drawer(
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
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          // Common
          drawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StaffProfileScreen(staff: staff)),
            ),
          ),
          drawerItem(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffChangePasswordScreen(email: staff['email']),
              ),
            ),
          ),

          // Role-specific
          if (role == 'waiter')
            drawerItem(
              context,
              icon: Icons.receipt_long,
              title: 'Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WaiterOrderScreen(staff: staff)),
              ),
            ),
          if (role == 'chef')
            drawerItem(
              context,
              icon: Icons.kitchen,
              title: 'Kitchen Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChefOrderScreen(staff: staff)),
              ),
            ),
          if (role == 'manager')
            drawerItem(
              context,
              icon: Icons.dashboard,
              title: 'Manager Dashboard',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerDashboardScreen(staff: staff),
                ),
              ),
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
    );
  }

  /// Dashboard shows cards (quick access)
  Widget _buildDashboard(BuildContext context, String role) {
    List<Widget> items = [
      dashboardCard(
        context,
        icon: Icons.lock,
        title: 'Change Password',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffChangePasswordScreen(email: staff['email']),
          ),
        ),
      ),
    ];

    if (role == 'waiter') {
      items.add(
        dashboardCard(
          context,
          icon: Icons.receipt_long,
          title: 'Orders',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WaiterOrderScreen(staff: staff)),
          ),
        ),
      );
    } else if (role == 'chef') {
      items.add(
        dashboardCard(
          context,
          icon: Icons.kitchen,
          title: 'Kitchen Orders',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChefOrderScreen(staff: staff)),
          ),
        ),
      );
    } else if (role == 'manager') {
      items.add(
        dashboardCard(
          context,
          icon: Icons.dashboard,
          title: 'Reports & Staff',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerDashboardScreen(staff: staff),
            ),
          ),
        ),
      );
    }

    // Grid only if more than 1 item
    if (items.length > 1) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: items,
      );
    } else {
      return Center(child: items.first);
    }
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
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap,
    );
  }
}
