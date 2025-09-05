import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class WaiterOrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const WaiterOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<WaiterOrderDetailsScreen> createState() => _WaiterOrderDetailsScreenState();
}

class _WaiterOrderDetailsScreenState extends State<WaiterOrderDetailsScreen> {
  Map<String, dynamic>? order;
  bool isLoading = true;

  final String baseUrl = "http://10.0.2.2:5000";

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        final found = data.cast<Map<String, dynamic>>().firstWhere(
          (o) => o['id'] == widget.orderId,
          orElse: () => {},
        );

        setState(() {
          order = found.isEmpty ? null : found;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateItemStatus(int itemId, String currentStatus) async {
    String newStatus;
    if (currentStatus == 'pending') {
      newStatus = 'preparing';
    } else if (currentStatus == 'preparing') {
      newStatus = 'served';
    } else {
      return; // already served
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/order_item/$itemId/status'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        _fetchOrderDetails(); // refresh after update
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'served':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'served':
        return 'Served';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Order not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Table: ${order!['table']}',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Order #${order!['id']}',
                          style: GoogleFonts.poppins(fontSize: 16)),
                      Text('Total: ₹${order!['total']}',
                          style: GoogleFonts.poppins(fontSize: 16)),
                      const SizedBox(height: 16),
                      Text('Items:',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: order!['items'].length,
                          itemBuilder: (context, index) {
                            final item = order!['items'][index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  "${item['name']} x${item['quantity']}",
                                  style: GoogleFonts.poppins(),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Text("Status: "),
                                    Chip(
                                      label: Text(
                                        _formatStatus(item['status']),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor:
                                          _getStatusColor(item['status']),
                                    ),
                                  ],
                                ),
                                trailing: item['status'] != 'served'
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                        ),
                                        onPressed: () => _updateItemStatus(
                                            item['id'], item['status']),
                                        child: Text(
                                          item['status'] == 'pending'
                                              ? "Start"
                                              : "Mark Served",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.check_circle,
                                        color: Colors.green),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
