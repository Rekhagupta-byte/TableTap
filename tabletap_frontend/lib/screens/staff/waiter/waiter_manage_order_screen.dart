import 'package:flutter/material.dart';

class WaiterManageOrderScreen extends StatelessWidget {
  const WaiterManageOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: const Center(child: Text("Staff Orders Screen")),
    );
  }
}
