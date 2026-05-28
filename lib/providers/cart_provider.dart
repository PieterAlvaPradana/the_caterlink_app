import 'package:flutter/foundation.dart';
import '../models/seller_menu_item.dart';

class CartItemModel {
  final SellerMenuItem item;
  int quantity;

  CartItemModel({required this.item, this.quantity = 1});

  double get totalPrice => item.price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.item.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(SellerMenuItem item) {
    if (_items.containsKey(item.id)) {
      _items.update(
        item.id,
        (existing) => CartItemModel(
          item: existing.item,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        item.id,
        () => CartItemModel(item: item, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void removeSingleItem(String itemId) {
    if (!_items.containsKey(itemId)) return;

    if (_items[itemId]!.quantity > 1) {
      _items.update(
        itemId,
        (existing) => CartItemModel(
          item: existing.item,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(itemId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
