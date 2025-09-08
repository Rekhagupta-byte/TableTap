import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/screens/staff/common/staff_profile_screen.dart';
import 'waiter_order_screen.dart';

import '../../auth/staff_change_password_screen.dart';

class WaiterHomeScreen extends StatefulWidget {
  final Map<String, dynamic> staff;

  const WaiterHomeScreen({super.key, required this.staff});

  @override
  State<WaiterHomeScreen> createState() => _WaiterHomeScreenState();
}

class _WaiterHomeScreenState extends State<WaiterHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      WaiterOrderScreen(staff: widget.staff),
      StaffProfileScreen(staff: widget.staff),
      StaffChangePasswordScreen(staff: widget.staff),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Waiter Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
  accountName: Text(widget.staff['name'] ?? 'Waiter'),
  accountEmail: Text(widget.staff['email'] ?? ''),
  currentAccountPicture: GestureDetector(
    onTap: () {
      Navigator.pop(context);       // Close the drawer
      _onItemTapped(1);             // Navigate to Profile screen
    },
    child: CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        widget.staff['name'] != null && widget.staff['name'].isNotEmpty
            ? widget.staff['name'][0].toUpperCase()
            : 'W',
        style: const TextStyle(fontSize: 24, color: Colors.deepPurple),
      ),
    ),
  ),
  decoration: const BoxDecoration(
    color: Colors.deepPurple,
  ),
),

            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // clear SharedPreferences and navigate to login
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

