import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/screens/staff/chef/chef_order_screen.dart';
import 'package:tabletap_frontend/screens/staff/common/staff_notification_screen.dart';
import 'package:tabletap_frontend/screens/staff/manager/manager_dashboard_screen.dart';
import 'package:tabletap_frontend/screens/staff/waiter/waiter_order_screen.dart' show WaiterOrderScreen;
import '../../auth/staff_change_password_screen.dart';
import 'staff_profile_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  final Map<String, dynamic>? staff;
  const StaffHomeScreen({super.key, this.staff});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  Map<String, dynamic> staff = {};
  String role = '';
  String roleName = '';

 @override
void initState() {
  super.initState();
  print("DEBUG: StaffHomeScreen initState called");
  _loadStaff();
}

Future<void> _loadStaff() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (widget.staff != null) {
    staff = widget.staff!;
  } else {
    final stored = prefs.getString('staffInfo');
    if (stored != null) {
      staff = jsonDecode(stored);
    }
  }

  // Normalize role
  role = (staff['role'] ?? '').toString().trim().toLowerCase();
  roleName = role.isNotEmpty ? '${role[0].toUpperCase()}${role.substring(1)}' : 'Staff';

  // Update cache if role changed
  staff['role'] = role;
  await prefs.setString('staffInfo', jsonEncode(staff));

  setState(() {});

  // First-time password change
  if (!(staff['is_password_changed'] ?? true)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToChangePassword();
    });
  }

  debugPrint('Staff loaded: $staff');
  debugPrint('Normalized role: $role'); // should print waiter, chef, or manager
}


  void _navigateToChangePassword() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StaffChangePasswordScreen(
        staff: staff,
        firstTime: true,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleName Dashboard', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: _buildDrawer(),
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
            Expanded(child: _buildDashboardCards()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
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
                style: GoogleFonts.poppins(fontSize: 24, color: Colors.deepPurple),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          drawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StaffProfileScreen(staff: staff)),
            ),
          ),
          drawerItem(icon: Icons.lock, title: 'Change Password', onTap: _navigateToChangePassword),
          drawerItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StaffNotificationsScreen(staff: staff)),
            ),
          ),
          const Divider(),
          if (role == 'waiter')
            drawerItem(
              icon: Icons.receipt_long,
              title: 'Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WaiterOrderScreen(staff: staff)),
              ),
            ),
          if (role == 'chef')
            drawerItem(
              icon: Icons.kitchen,
              title: 'Kitchen Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChefOrderScreen(staff: staff)),
              ),
            ),
          if (role == 'manager')
            drawerItem(
              icon: Icons.dashboard,
              title: 'Manager Dashboard',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManagerDashboardScreen(staff: staff)),
              ),
            ),
          const Divider(),
          drawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    List<Widget> cards = [
      dashboardCard(icon: Icons.lock, title: 'Change Password', onTap: _navigateToChangePassword),
    ];

    if (role == 'waiter') {
      cards.add(dashboardCard(
        icon: Icons.receipt_long,
        title: 'Orders',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WaiterOrderScreen(staff: staff)),
        ),
      ));
    } else if (role == 'chef') {
      cards.add(dashboardCard(
        icon: Icons.kitchen,
        title: 'Kitchen Orders',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChefOrderScreen(staff: staff)),
        ),
      ));
    } else if (role == 'manager') {
      cards.add(dashboardCard(
        icon: Icons.dashboard,
        title: 'Reports & Staff',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ManagerDashboardScreen(staff: staff)),
        ),
      ));
    }

    return cards.length > 1
        ? GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: cards,
          )
        : Center(child: cards.first);
  }

  Widget dashboardCard({required IconData icon, required String title, required VoidCallback onTap}) {
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
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap,
    );
  }
}
