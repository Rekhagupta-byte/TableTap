import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    // Clear user session if needed
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              "Owner",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("you@example.com", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
