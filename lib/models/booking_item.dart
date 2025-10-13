enum BookingStatus { pending, approved, rejected, completed, cancelled }

class BookingItemModel {
  final String productId;
  final int quantity;
  final double pricePerUnit;
  final String productName;

  BookingItemModel({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
    required this.productName,
  });

  factory BookingItemModel.fromMap(Map<String, dynamic> data) {
    return BookingItemModel(
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 0,
      pricePerUnit: (data['pricePerUnit'] ?? 0.0).toDouble(),
      productName: data['productName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'productName': productName,
    };
  }

  double get totalPrice => quantity * pricePerUnit;
}
