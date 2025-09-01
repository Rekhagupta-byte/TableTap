import 'package:flutter/foundation.dart';
import 'menu_item.dart'; 

class CartModel extends ChangeNotifier {
  final Map<MenuItem, int> _items = {};

  Map<MenuItem, int> get items => _items;

  void addItem(MenuItem item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  void decreaseItem(MenuItem item) {
    if (_items.containsKey(item)) {
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
      }
      notifyListeners();
    }
  }

  void removeItem(MenuItem item) {
    if (_items.containsKey(item)) {
      _items.remove(item);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.entries
        .fold(0.0, (sum, entry) => sum + entry.key.price * entry.value);
  }

  bool get isEmpty => _items.isEmpty;
}
