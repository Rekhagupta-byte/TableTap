import 'package:flutter/material.dart';

class ManagerDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> staff;
  const ManagerDashboardScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manager Dashboard")),
      body: const Center(child: Text("Manager Dashboard (coming soon)")),
    );
  }
}
