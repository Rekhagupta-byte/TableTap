import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'menu_item.dart'; // Your MenuItem model

class OrderModel with ChangeNotifier {
  Map<MenuItem, int> _lastOrder = {};

  Map<MenuItem, int> get lastOrder => _lastOrder;

  void setOrder(Map<MenuItem, int> order) {
    _lastOrder = order;
    notifyListeners();
  }

  Future<void> fetchLastOrder(String tableNumber) async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.0.244:5000/customer/last-order?table_number=$tableNumber"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Map<MenuItem, int> loadedOrder = {};
        for (var item in data["items"]) {
          loadedOrder[MenuItem(
            id: item["id"],
            name: item["name"],
            price: (item["price"] as num).toDouble(),
            category: item["category"] ?? '',        // Optional field fallback
            imageUrl: item["image_url"] ?? '',
          )] = item["quantity"] ?? 1;
        }

        _lastOrder = loadedOrder;
      } else {
        _lastOrder = {};
      }
    } catch (e) {
      _lastOrder = {};
    }
    notifyListeners();
  }
}
