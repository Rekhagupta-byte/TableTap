import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffOrderScreen extends StatefulWidget {
  final Map<String, dynamic> staff;
  const StaffOrderScreen({super.key, required this.staff});

  @override
  State<StaffOrderScreen> createState() => _StaffOrdersScreenState();
}

class _StaffOrdersScreenState extends State<StaffOrderScreen> {
  // Sample orders (you will replace with API data)
  List<Map<String, dynamic>> orders = [
    {
      'id': 101,
      'table': '5',
      'items': ['Burger', 'Fries'],
      'status': 'Pending',
      'total': 250,
      'isNew': true
    },
    {
      'id': 102,
      'table': '2',
      'items': ['Pizza'],
      'status': 'In Progress',
      'total': 180,
      'isNew': false
    },
    {
      'id': 103,
      'table': '3',
      'items': ['Pasta', 'Coke'],
      'status': 'Completed',
      'total': 220,
      'isNew': false
    },
  ];

  void _updateStatus(int index) {
    setState(() {
      if (orders[index]['status'] == 'Pending') {
        orders[index]['status'] = 'In Progress';
      } else if (orders[index]['status'] == 'In Progress') {
        orders[index]['status'] = 'Completed';
      }
      orders[index]['isNew'] = false; // mark as viewed/handled
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(order['status']),
                child: Text(order['table'],
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text('Order #${order['id']}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Items: ${order['items'].join(', ')}',
                        style: GoogleFonts.poppins(fontSize: 14)),
                    Text('Total: \$${order['total']}',
                        style: GoogleFonts.poppins(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Status: ',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(order['status'],
                              style: const TextStyle(color: Colors.white)),
                        ),
                        if (order['isNew'] == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                  ]),
              trailing: order['status'] != 'Completed'
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      onPressed: () => _updateStatus(index),
                      child: Text(
                          order['status'] == 'Pending'
                              ? 'Start'
                              : 'Complete',
                          style: const TextStyle(color: Colors.white)),
                    )
                  : null,
              onTap: () {
                // Optional: navigate to detailed order view
              },
            ),
          );
        },
      ),
    );
  }
}
