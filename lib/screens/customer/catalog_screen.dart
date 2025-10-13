import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../widgets/customer/product_filters.dart';
import '../../widgets/customer/product_grid.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
        productProvider.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Rental Catalog'),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        ProductFilters(),
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (productProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(productProvider.errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => productProvider.loadProducts(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return ProductGrid(products: productProvider.products, crossAxisCount: 2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(width: 300, child: ProductFilters(isDrawer: false)),
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (productProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(productProvider.errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => productProvider.loadProducts(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return ProductGrid(products: productProvider.products, crossAxisCount: 3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
      child: Row(
        children: [
          SizedBox(width: 350, child: ProductFilters(isDrawer: false)),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (productProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(productProvider.errorMessage!),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productProvider.loadProducts(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return ProductGrid(products: productProvider.products, crossAxisCount: 4);
              },
            ),
          ),
        ],
      ),
    );
  }
}
