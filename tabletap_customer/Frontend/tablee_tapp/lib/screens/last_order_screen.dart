import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LastOrderScreen extends StatefulWidget {
  final int tableNumber; // Pass this when navigating from QR scan
  const LastOrderScreen({super.key, required this.tableNumber});

  @override
  State<LastOrderScreen> createState() => _LastOrderScreenState();
}

class _LastOrderScreenState extends State<LastOrderScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? lastOrder;

  @override
  void initState() {
    super.initState();
    _fetchLastOrder();
  }

  Future<void> _fetchLastOrder() async {
    final url = Uri.parse(
      "http://192.168.0.244:5000/last-order?table_number=${widget.tableNumber}",
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          lastOrder = json.decode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          lastOrder = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        lastOrder = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Last Order"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : lastOrder == null
              ? const Center(child: Text("No previous order found."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: lastOrder!['items'].length,
                        itemBuilder: (context, index) {
                          final item = lastOrder!['items'][index];
                          final imageUrl = (item['image_url'] ?? "") as String;
                          final price = (item['price'] as num).toDouble();
                          final quantity = (item['quantity'] as num).toInt();

                          return ListTile(
                            leading: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(item['name']),
                            subtitle: Text("Quantity: $quantity"),
                            trailing: Text(
                              "₹${(price * quantity).toStringAsFixed(2)}",
                            ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "₹${(lastOrder!['total_price'] as num).toDouble().toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/order-status',
                                arguments: {"orderId": lastOrder!['id']},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text("View Status"),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text("Back to Home"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
