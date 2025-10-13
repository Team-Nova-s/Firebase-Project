import 'package:flutter/material.dart';
import 'package:papela/widgets/customer/product_card.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final featuredProducts = productProvider.products.take(8).toList();

        if (featuredProducts.isEmpty) {
          return SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                'Featured Products',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      margin: EdgeInsets.only(right: 16),
                      child: ProductCard(product: featuredProducts[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
