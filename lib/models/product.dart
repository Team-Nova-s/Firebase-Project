import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final int quantity;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.imageUrls,
    required this.specifications,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      specifications: data['specifications'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'quantity': quantity,
      'imageUrls': imageUrls,
      'specifications': specifications,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isAvailable => quantity > 0;
}
