import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class ProductFilters extends StatefulWidget {
  final bool isDrawer;

  const ProductFilters({super.key, this.isDrawer = true});

  @override
  State<ProductFilters> createState() => _ProductFiltersState();
}

class _ProductFiltersState extends State<ProductFilters> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      _searchController.text = productProvider.searchQuery;
      _priceRange = RangeValues(productProvider.minPrice, productProvider.maxPrice);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDrawer) {
      return _buildMobileFilters();
    } else {
      return _buildDesktopFilters();
    }
  }

  Widget _buildMobileFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          SizedBox(width: 16),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          _buildSearchField(),
          SizedBox(height: 24),
          _buildCategoryFilter(),
          SizedBox(height: 24),
          _buildPriceFilter(),
          SizedBox(height: 24),
          _buildClearFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            productProvider.setSearchQuery(value);
          },
        );
      },
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      onPressed: () => _showFiltersBottomSheet(),
      icon: Icon(Icons.filter_list),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  _buildCategoryOption(
                    context,
                    null,
                    'All Categories',
                    productProvider.selectedCategoryId == null,
                    productProvider,
                  ),
                  ...productProvider.categories.map(
                    (category) => _buildCategoryOption(
                      context,
                      category.id,
                      category.name,
                      productProvider.selectedCategoryId == category.id,
                      productProvider,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryOption(
    BuildContext context,
    String? categoryId,
    String name,
    bool isSelected,
    ProductProvider productProvider,
  ) {
    return InkWell(
      onTap: () => productProvider.setSelectedCategory(categoryId),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GH₵${_priceRange.start.round()}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      Text(
                        'GH₵${_priceRange.end.round()}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withValues(alpha: 0.3),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    onChangeEnd: (values) {
                      productProvider.setPriceRange(values.start, values.end);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClearFiltersButton() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final hasActiveFilters =
            productProvider.searchQuery.isNotEmpty ||
            productProvider.selectedCategoryId != null ||
            productProvider.minPrice > 0 ||
            productProvider.maxPrice < 1000;

        if (!hasActiveFilters) {
          return SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              productProvider.clearFilters();
              _searchController.clear();
              setState(() {
                _priceRange = RangeValues(0, 1000);
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear_all, size: 20),
                SizedBox(width: 8),
                Text('Clear Filters'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryFilter(),
                    SizedBox(height: 24),
                    _buildPriceFilter(),
                    SizedBox(height: 24),
                    _buildClearFiltersButton(),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
