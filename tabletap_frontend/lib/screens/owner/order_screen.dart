import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dummyOrders = [
    {
      'table': 5,
      'items': ['Pizza', 'Cola'],
      'status': 'Pending',
    },
    {
      'table': 3,
      'items': ['Burger', 'Fries'],
      'status': 'Completed',
    },
    {
      'table': 7,
      'items': ['Pasta', 'Water'],
      'status': 'Preparing',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'Preparing':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyOrders.length,
      itemBuilder: (context, index) {
        final order = dummyOrders[index];
        return Card(
          margin: EdgeInsets.all(12),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${order['table']}'),
              backgroundColor: Colors.orangeAccent,
            ),
            title: Text("Table ${order['table']}"),
            subtitle: Text("Items: ${order['items'].join(', ')}"),
            trailing: Text(
              order['status'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order['status']),
              ),
            ),
          ),
        );
      },
    );
  }
}
