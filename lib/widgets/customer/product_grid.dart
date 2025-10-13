import 'package:flutter/material.dart';
import 'package:papela/models/product.dart';
import 'package:papela/widgets/customer/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final int crossAxisCount;

  const ProductGrid({super.key, required this.products, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('No products found', textAlign: TextAlign.center),
              subtitle: Text(
                'Try adjusting your filters or search terms',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.45,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}
