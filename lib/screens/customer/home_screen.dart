import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../widgets/customer/category_grid.dart';
import '../../widgets/customer/featured_products.dart';
import '../../widgets/customer/hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: CustomAppBar(title: AppConstants.appName),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          SizedBox(height: 32),
          CategoryGrid(crossAxisCount: 2),
          SizedBox(height: 32),
          FeaturedProducts(),
          SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          SizedBox(height: 48),
          CategoryGrid(crossAxisCount: 3),
          SizedBox(height: 48),
          FeaturedProducts(),
          SizedBox(height: 48),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          SizedBox(height: 64),
          Container(
            constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
            child: Column(
              children: [
                CategoryGrid(crossAxisCount: 4),
                SizedBox(height: 64),
                FeaturedProducts(),
                SizedBox(height: 64),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(32),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 32,
              ),
              SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Your trusted partner for event rentals in Accra',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 16,
              ),
              SizedBox(width: 4),
              Text('+233 54 859 1362'),
              SizedBox(width: 16),
              Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 16,
              ),
              SizedBox(width: 4),
              Text('buadunyo@gmail.com'),
            ],
          ),
        ],
      ),
    );
  }
}
