import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:papela/models/category.dart';
import 'package:papela/models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;
  double _minPrice = 0;
  double _maxPrice = 1000;

  List<ProductModel> get products => _filteredProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    debugPrint(_errorMessage);
    notifyListeners();
  }

  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Error loading products: $e');
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Error loading categories: $e');
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
    } catch (e) {
      _setError('Error loading product: $e');
    }
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _minPrice = 0;
    _maxPrice = 1000;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery) &&
          !product.description.toLowerCase().contains(_searchQuery)) {
        return false;
      }

      // Category filter
      if (_selectedCategoryId != null && product.categoryId != _selectedCategoryId) {
        return false;
      }

      // Price filter
      if (product.price < _minPrice || product.price > _maxPrice) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Admin functions
  Future<bool> addProduct(ProductModel product) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('products').add(product.toFirestore());
      await loadProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error adding product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(String productId, ProductModel product) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('products').doc(productId).update(product.toFirestore());
      await loadProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('products').doc(productId).delete();
      await loadProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> checkAvailability(String productId, int quantity, DateTime eventDate) async {
    try {
      // Get product current stock
      DocumentSnapshot productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) return false;

      ProductModel product = ProductModel.fromFirestore(productDoc);
      if (product.quantity < quantity) return false;

      // Check for conflicting bookings on the same date
      QuerySnapshot bookings = await _firestore
          .collection('bookings')
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(eventDate))
          .where('eventDate', isLessThan: Timestamp.fromDate(eventDate.add(Duration(days: 1))))
          .where('status', whereIn: ['approved', 'pending'])
          .get();

      int bookedQuantity = 0;
      for (var booking in bookings.docs) {
        Map<String, dynamic> data = booking.data() as Map<String, dynamic>;
        List items = data['items'] ?? [];
        for (var item in items) {
          if (item['productId'] == productId) {
            bookedQuantity += item['quantity'] as int;
          }
        }
      }

      return (product.quantity - bookedQuantity) >= quantity;
    } catch (e) {
      _setError('Error checking availability: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
