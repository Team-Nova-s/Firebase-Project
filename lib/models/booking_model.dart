import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/booking_item.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<BookingItemModel> items;
  final DateTime eventDate;
  final String eventLocation;
  final BookingStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final String notes;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.eventDate,
    required this.eventLocation,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.notes,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      items: (data['items'] as List? ?? []).map((item) => BookingItemModel.fromMap(item)).toList(),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventLocation: data['eventLocation'] ?? '',
      status: BookingStatus.values.firstWhere(
        (status) => status.toString() == 'BookingStatus.${data['status']}',
        orElse: () => BookingStatus.pending,
      ),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'eventDate': Timestamp.fromDate(eventDate),
      'eventLocation': eventLocation,
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.approved:
        return AppColors.success;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }
}
