import 'package:flutter/material.dart';
import 'package:papela/models/cart_item.dart';
import 'package:papela/models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  DateTime? _eventDate;
  String _eventLocation = '';
  String _eventNotes = '';

  Map<String, CartItemModel> get items => Map.from(_items);
  List<CartItemModel> get cartItems => _items.values.toList();
  int get itemCount => _items.length;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;
  DateTime? get eventDate => _eventDate;
  String get eventLocation => _eventLocation;
  String get eventNotes => _eventNotes;

  void addItem(ProductModel product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + quantity,
      );
    } else {
      _items[product.id] = CartItemModel(
        productId: product.id,
        quantity: quantity,
        product: product,
      );
    }
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId] = _items[productId]!.copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _eventDate = null;
    _eventLocation = '';
    _eventNotes = '';
    notifyListeners();
  }

  void setEventDetails({DateTime? eventDate, String? eventLocation, String? eventNotes}) {
    if (eventDate != null) _eventDate = eventDate;
    if (eventLocation != null) _eventLocation = eventLocation;
    if (eventNotes != null) _eventNotes = eventNotes;
    notifyListeners();
  }

  bool canCheckout() {
    return _items.isNotEmpty && _eventDate != null && _eventLocation.isNotEmpty;
  }

  CartItemModel? getItem(String productId) {
    return _items[productId];
  }

  bool containsProduct(String productId) {
    return _items.containsKey(productId);
  }
}
