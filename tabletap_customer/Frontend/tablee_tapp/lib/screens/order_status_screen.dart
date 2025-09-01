import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderStatusScreen extends StatefulWidget {
  final int orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  String orderStatus = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchOrderStatus();
  }

  Future<void> fetchOrderStatus() async {
    final url = Uri.parse(
        "http://192.168.0.244:5000/order-status/${widget.orderId}");
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          orderStatus = (data["status"] ?? "Unknown").toString();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Server Error: ${res.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch status.\n$e";
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'preparing':
        return Icons.kitchen;
      case 'ready':
        return Icons.done;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Status"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Card(
                    color: Colors.red[50],
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(getStatusIcon(orderStatus),
                              size: 80, color: getStatusColor(orderStatus)),
                          const SizedBox(height: 20),
                          const Text(
                            "Current Order Status",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            orderStatus,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(orderStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
