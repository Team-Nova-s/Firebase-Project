import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/product.dart';
import 'package:papela/widgets/admin/product_dialog_form.dart';
import 'package:papela/widgets/admin/product_management_table.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProducts();
      productProvider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Management',
        showCart: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              productProvider.loadProducts();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (productProvider.errorMessage != null) {
          return _buildErrorView(productProvider);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (productProvider.errorMessage != null) {
          return _buildErrorView(productProvider);
        }

        return Padding(
          padding: EdgeInsets.all(24),
          child: ProductManagementTable(
            products: productProvider.products,
            onEdit: (product) => _showProductDialog(product: product),
            onDelete: _deleteProduct,
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (productProvider.errorMessage != null) {
          return _buildErrorView(productProvider);
        }

        return Container(
          constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products (${productProvider.products.length})',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(),
                    icon: Icon(Icons.add),
                    label: Text('Add Product'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Expanded(
                child: ProductManagementTable(
                  products: productProvider.products,
                  onEdit: (product) => _showProductDialog(product: product),
                  onDelete: _deleteProduct,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported),
                          ),
                        )
                      : Icon(Icons.image_not_supported),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('GH₵ ${product.price.toStringAsFixed(2)}'),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            product.isAvailable ? Icons.check_circle : Icons.cancel,
                            color: product.isAvailable ? AppColors.success : AppColors.error,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Qty: ${product.quantity}',
                            style: TextStyle(
                              color: product.isAvailable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showProductDialog(product: product),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit'),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteProduct(product),
                  icon: Icon(Icons.delete, size: 16, color: AppColors.error),
                  label: Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(ProductProvider productProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(productProvider.errorMessage!),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () => productProvider.loadProducts(), child: Text('Retry')),
        ],
      ),
    );
  }

  void _showProductDialog({ProductModel? product}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final success = await productProvider.deleteProduct(product.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
