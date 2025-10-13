import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/product.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: InkWell(
        onTap: () => context.go('/product/${product.id}'),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppConstants.borderRadius),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) {
                            return _buildFallbackImage();
                          },
                        ),
                      )
                    : _buildFallbackImage(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      'GH₵${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.isAvailable ? 'Available' : 'Out of Stock'),
                      trailing: product.isAvailable
                          ? Consumer2<AuthProvider, CartProvider>(
                              builder: (context, authProvider, cartProvider, child) {
                                return IconButton(
                                  onPressed: () => _addToCart(context, authProvider, cartProvider),
                                  icon: Icon(Icons.add_shopping_cart),
                                  iconSize: 20,
                                );
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Center(child: Icon(Icons.image_outlined, size: 48, color: Colors.grey));
  }

  void _addToCart(BuildContext context, AuthProvider authProvider, CartProvider cartProvider) {
    if (!authProvider.isAuthenticated) {
      context.go('/login');
      return;
    }

    cartProvider.addItem(product, 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(label: 'View Cart', onPressed: () => context.go('/cart')),
      ),
    );
  }
}
