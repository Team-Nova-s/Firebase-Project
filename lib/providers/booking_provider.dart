import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:papela/models/booking_item.dart';
import 'package:papela/models/cart_item.dart';
import 'package:papela/models/user.dart';

import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> _customerBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get customerBookings => _customerBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    debugPrint(error);
    notifyListeners();
  }

  Future<bool> submitBooking({
    required UserModel customer,
    required List<CartItemModel> items,
    required DateTime eventDate,
    required String eventLocation,
    required String notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      List<BookingItemModel> bookingItems = items.map((cartItem) {
        return BookingItemModel(
          productId: cartItem.productId,
          quantity: cartItem.quantity,
          pricePerUnit: cartItem.product.price,
          productName: cartItem.product.name,
        );
      }).toList();

      double totalAmount = bookingItems.fold(0.0, (s, item) => s + item.totalPrice);

      BookingModel booking = BookingModel(
        id: '', // Will be set by Firestore
        customerId: customer.id,
        customerName: customer.name,
        customerEmail: customer.email,
        customerPhone: customer.phone,
        items: bookingItems,
        eventDate: eventDate,
        eventLocation: eventLocation,
        status: BookingStatus.pending,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await _firestore.collection('bookings').add(booking.toFirestore());

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error submitting booking: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadAllBookings() async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .get();

      _bookings = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Error loading bookings: $e');
      _setLoading(false);
    }
  }

  Future<void> loadCustomerBookings(String customerId) async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      _customerBookings = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Error loading customer bookings: $e');
      _setLoading(false);
    }
  }

  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });

      // Reload bookings to reflect changes
      await loadAllBookings();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating booking status: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
    } catch (e) {
      _setError('Error loading booking: $e');
    }
    return null;
  }

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  int getPendingBookingsCount() {
    return _bookings.where((booking) => booking.status == BookingStatus.pending).length;
  }

  double getTotalRevenue() {
    return _bookings
        .where((booking) => booking.status == BookingStatus.completed)
        .fold(0.0, (s, booking) => s + booking.totalAmount);
  }

  double getMonthlyRevenue() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    return _bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.completed && booking.createdAt.isAfter(startOfMonth),
        )
        .fold(0.0, (s, booking) => s + booking.totalAmount);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
