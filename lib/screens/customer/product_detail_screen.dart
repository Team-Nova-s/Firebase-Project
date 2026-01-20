import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/category.dart';
import 'package:papela/models/product.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/responsive_layout.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? product;
  CategoryModel? category;
  int quantity = 1;
  bool isLoading = true;
  String? errorMessage;
  DateTime? selectedEventDate;
  bool isCheckingAvailability = false;
  bool isAvailableForDate = true;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final loadedProduct = await productProvider.getProduct(widget.productId);

      if (loadedProduct != null && mounted) {
        // Load category info
        final categories = productProvider.categories;
        final productCategory = categories.firstWhere(
          (cat) => cat.id == loadedProduct.categoryId,
          orElse: () => CategoryModel(id: '', name: 'Unknown', description: '', imageUrl: ''),
        );

        setState(() {
          product = loadedProduct;
          category = productCategory;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Product not found';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading product: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAvailability() async {
    if (product == null || selectedEventDate == null) return;

    setState(() {
      isCheckingAvailability = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final available = await productProvider.checkAvailability(
      product!.id,
      quantity,
      selectedEventDate!,
    );

    setState(() {
      isAvailableForDate = available;
      isCheckingAvailability = false;
    });
  }

  Future<void> _addToCart() async {
    if (product == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      context.go('/login');
      return;
    }

    // Check availability if date is selected
    if (selectedEventDate != null && !isAvailableForDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product is not available for the selected date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product!, quantity);

    // Set event date if selected
    if (selectedEventDate != null) {
      cartProvider.setEventDetails(eventDate: selectedEventDate);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product!.name} added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  Future<void> _selectEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEventDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Select Event Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedEventDate) {
      setState(() {
        selectedEventDate = picked;
      });
      _checkAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Loading...'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || product == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Error'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                errorMessage ?? 'Product not found',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                child: Text('Back to Catalog'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: product!.name),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                SizedBox(height: 24),
                _buildEventDateSelector(),
                SizedBox(height: 24),
                _buildQuantitySelector(),
                SizedBox(height: 24),
                _buildAddToCartButton(),
                SizedBox(height: 32),
                _buildRelatedProducts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildImageGallery()),
                SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(),
                      SizedBox(height: 32),
                      _buildEventDateSelector(),
                      SizedBox(height: 24),
                      _buildQuantitySelector(),
                      SizedBox(height: 32),
                      _buildAddToCartButton(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            _buildRelatedProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildImageGallery()),
                    SizedBox(width: 48),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(),
                          SizedBox(height: 32),
                          _buildEventDateSelector(),
                          SizedBox(height: 24),
                          _buildQuantitySelector(),
                          SizedBox(height: 32),
                          _buildAddToCartButton(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 64),
                _buildRelatedProducts(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                color: Colors.grey[200],
              ),
              child: product!.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: CachedNetworkImage(
                        imageUrl: product!.imageUrls[currentImageIndex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, error, stackTrace) {
                          return _buildFallbackImage();
                        },
                      ),
                    )
                  : _buildFallbackImage(),
            ),
          ),
          if (product!.imageUrls.length > 1) ...[
            SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product!.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentImageIndex == index ? AppColors.primary : Colors.grey[300]!,
                          width: currentImageIndex == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product!.imageUrls[index],
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image_outlined, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text('No image available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null && category!.name.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category!.name,
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        SizedBox(height: 12),
        Text(
          product!.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'GH₵${product!.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product!.isAvailable ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product!.isAvailable ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    product!.isAvailable ? 'Available (${product!.quantity})' : 'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedEventDate != null && isCheckingAvailability) ...[
              SizedBox(width: 12),
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
            if (selectedEventDate != null && !isCheckingAvailability) ...[
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailableForDate ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvailableForDate
                      ? 'Available for selected date'
                      : 'Not available for selected date',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 24),
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          product!.description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.5),
        ),
        if (product!.specifications.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'Specifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: product!.specifications.entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${entry.key}:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Select your event date to check availability',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: _selectEventDate,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedEventDate != null
                        ? '${selectedEventDate!.day}/${selectedEventDate!.month}/${selectedEventDate!.year}'
                        : 'Select event date',
                    style: TextStyle(
                      color: selectedEventDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
              icon: Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: quantity > 1 ? Colors.black87 : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(width: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quantity.toString(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 24),
            IconButton(
              onPressed: quantity < product!.quantity ? () => setState(() => quantity++) : null,
              icon: Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: quantity < product!.quantity
                    ? AppColors.primary
                    : Colors.grey[200],
                foregroundColor: quantity < product!.quantity ? Colors.white : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Max: ${product!.quantity}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: LoadingButton(
        onPressed: product!.isAvailable && quantity > 0 ? _addToCart : null,
        isLoading: false,
        backgroundColor: product!.isAvailable && quantity > 0
            ? AppColors.primary
            : Colors.grey[400],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined),
            SizedBox(width: 8),
            Text(
              product!.isAvailable
                  ? 'Add to Cart • GH₵${(product!.price * quantity).toStringAsFixed(2)}'
                  : 'Out of Stock',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final relatedProducts = productProvider.getRelatedProducts(product!.categoryId, product!.id);

        if (relatedProducts.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final relatedProduct = relatedProducts[index];
                return Card(
                  elevation: AppConstants.cardElevation,
                  child: InkWell(
                    onTap: () => context.go('/product/${relatedProduct.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppConstants.borderRadius),
                              ),
                            ),
                            child: relatedProduct.imageUrls.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(AppConstants.borderRadius),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: relatedProduct.imageUrls.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorWidget: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(Icons.image_outlined, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  )
                                : Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  relatedProduct.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                Text(
                                  'GH₵${relatedProduct.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
