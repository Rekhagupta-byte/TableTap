import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tabletap_frontend/utils/api_helper.dart';

import '../models/cart_model.dart';
import '../models/order_model.dart';
import 'order_sucess_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String tableNumber; // Pass dynamically

  const OrderSummaryScreen({super.key, this.tableNumber = "1"});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _placeOrder(BuildContext context) async {
    final cart = Provider.of<CartModel>(context, listen: false);
    final orderModel = Provider.of<OrderModel>(context, listen: false);


    final itemsList = cart.items.entries.map((entry) {
      final menuItem = entry.key;
      return {
        "id": menuItem.id,
        "name": menuItem.name,
        "price": menuItem.price,
        "category": menuItem.category,
        "image_url": menuItem.imageUrl,
        "quantity": entry.value,
      };
    }).toList();

    final totalPrice = cart.totalPrice;

    debugPrint("Sending order: ${jsonEncode({
      "table_number": widget.tableNumber,
      "items": itemsList,
      "total_price": totalPrice,
    })}");

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
  Uri.parse(api('/place-order')),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "table_number": widget.tableNumber,
    "items": itemsList,
    "total_price": totalPrice,
  }),
);

      debugPrint("Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 201) {
        Map<String, dynamic>? data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          _showSnackBar("Invalid JSON response: $e");
          return;
        }

        if (data != null && data.containsKey('order_id')) {
          final dynamic id = data['order_id'];
          final int orderId = (id is int) ? id : int.tryParse(id.toString()) ?? 0;

          if (orderId == 0) {
            _showSnackBar("Invalid order ID received.");
            return;
          }

          orderModel.setOrder(cart.items);
          cart.clearCart();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: orderId),
            ),
            (route) => false,
          );
        } else {
          _showSnackBar("Order ID missing in response.");
        }
      } else {
        _showSnackBar("Failed to place order: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception caught in _placeOrder: $e");
      _showSnackBar("Error placing order: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final total = cart.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ...cart.items.entries.map(
                        (entry) => ListTile(
                          title: Text(entry.key.name),
                          subtitle: Text("Qty: ${entry.value}"),
                          trailing: Text(
                            "₹${(entry.key.price * entry.value).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          "Total",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Back to cart"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _placeOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Confirm Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
