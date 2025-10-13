import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/category.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class CategoryGrid extends StatelessWidget {
  final int crossAxisCount;

  const CategoryGrid({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.categories.isEmpty) {
          return SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                'Browse by Category',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: productProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = productProvider.categories[index];
                  return CategoryCard(category: category);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: InkWell(
        onTap: () {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          productProvider.setSelectedCategory(category.id);
          context.go('/catalog');
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: category.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppConstants.borderRadius),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: category.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return _buildFallbackIcon();
                            },
                          ),
                        )
                      : _buildFallbackIcon(),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(child: Icon(_getCategoryIcon(), size: 48, color: AppColors.primary));
  }

  IconData _getCategoryIcon() {
    switch (category.name.toLowerCase()) {
      case 'chairs':
        return Icons.chair;
      case 'tables':
        return Icons.table_restaurant;
      case 'canopies':
      case 'tents':
        return Icons.festival;
      case 'decorations':
      case 'decor':
        return Icons.celebration;
      case 'linens':
      case 'tablecloths':
        return Icons.texture;
      default:
        return Icons.category;
    }
  }
}
