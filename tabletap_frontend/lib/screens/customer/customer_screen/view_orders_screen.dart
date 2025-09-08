import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tabletap_frontend/screens/customer/customer_screen/order_sucess_screen.dart';
import 'package:tabletap_frontend/utils/api_helper.dart';

class ViewOrdersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) incrementQty;
  final Function(int) decrementQty;
  final Function(int) removeItem;

  const ViewOrdersScreen({
    super.key,
    required this.cartItems,
    required this.incrementQty,
    required this.decrementQty,
    required this.removeItem,
  });

  double getTotalAmount() {
    return cartItems.fold(
      0.0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

  
    const String tableNumber = "1"; // TODO: Replace with actual table logic

    try {
      final response = await http.post(
  Uri.parse(api('/place-order')),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "table_number": tableNumber,
    "items": cartItems,
    "total_price": getTotalAmount(),
  }),
);


      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        debugPrint("Decoded response data: $data");

        if (data != null && data.containsKey('order_id')) {
          // Parse order_id safely whether int or string
          final dynamic id = data['order_id'];
          final int orderId = id is int ? id : int.tryParse(id.toString()) ?? 0;

          if (orderId == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid order ID received.")),
            );
            return;
          }

          // Navigate to success screen with orderId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: orderId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order ID missing in response.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint("Exception during order placement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Orders"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          title: Text(item['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("₹${item['price']}"),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => decrementQty(index),
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => incrementQty(index),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => removeItem(index),
                                child: const Text(
                                  "Remove",
                                  style: TextStyle(color: Colors.red),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("₹${getTotalAmount().toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _placeOrder(context),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Place Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
