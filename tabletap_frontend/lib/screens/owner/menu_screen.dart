import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final String tableNumber;

  const MenuScreen({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu for Table $tableNumber"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          "Display menu for table $tableNumber here.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
