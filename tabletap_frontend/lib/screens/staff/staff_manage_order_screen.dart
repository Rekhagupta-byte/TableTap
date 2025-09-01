import 'package:flutter/material.dart';

class StaffManageOrdersScreen extends StatelessWidget {
  const StaffManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: const Center(child: Text("Staff Orders Screen")),
    );
  }
}
