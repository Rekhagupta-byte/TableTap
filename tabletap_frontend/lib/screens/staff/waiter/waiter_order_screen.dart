import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// Import your details screen here
import 'waiter_order_details_screen.dart';

class WaiterOrderScreen extends StatefulWidget {
  final Map<String, dynamic> staff;
  const WaiterOrderScreen({super.key, required this.staff});

  @override
  State<WaiterOrderScreen> createState() => _WaiterOrderScreenState();
}

class _WaiterOrderScreenState extends State<WaiterOrderScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  final String baseUrl = "http://192.168.0.244:5000";

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          orders = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    }
  }

  Future<void> _updateStatus(int index) async {
    final order = orders[index];

    String newStatus;
    if (order['status'] == 'pending') {
      newStatus = 'in_progress';
    } else if (order['status'] == 'in_progress') {
      newStatus = 'completed';
    } else {
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/order/${order['id']}/status'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          orders[index]['status'] = newStatus;
          orders[index]['isNew'] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order['id']} updated!')),
        );
      } else {
        throw Exception('Failed to update order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiter Orders', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WaiterOrderDetailsScreen(orderId: order['id']),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            _getStatusColor(order['status']),
                                        child: Text(order['table'].toString(),
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Order #${order['id']}',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  if (order['isNew'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('NEW',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Items: ${order['items'].join(', ')}',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              Text('Total: ₹${order['total']}',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Status: ',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(_formatStatus(order['status']),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (order['status'] != 'completed')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateStatus(index),
                                    child: Text(
                                      order['status'] == 'pending'
                                          ? 'Start Order'
                                          : 'Mark Completed',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
