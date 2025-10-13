import 'package:papela/models/product.dart';

class CartItemModel {
  final String productId;
  final int quantity;
  final ProductModel product;

  CartItemModel({required this.productId, required this.quantity, required this.product});

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({String? productId, int? quantity, ProductModel? product}) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
