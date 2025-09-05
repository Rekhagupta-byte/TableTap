import 'package:flutter/material.dart';

class ChefOrderScreen extends StatelessWidget {
  final Map<String, dynamic> staff;
  const ChefOrderScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chef Orders")),
      body: const Center(child: Text("Chef Order Screen (coming soon)")),
    );
  }
}
