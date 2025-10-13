import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/cart_item.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/responsive_layout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventNotesController = TextEditingController();
  DateTime? _selectedEventDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      _eventLocationController.text = cartProvider.eventLocation;
      _eventNotesController.text = cartProvider.eventNotes;
      _selectedEventDate = cartProvider.eventDate;
    });
  }

  @override
  void dispose() {
    _eventLocationController.dispose();
    _eventNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Shopping Cart', showCart: false),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart();
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(cartProvider),
            tablet: _buildTabletLayout(cartProvider),
            desktop: _buildDesktopLayout(cartProvider),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 120, color: Colors.grey[400]),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Add some items to your cart to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/catalog'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined),
                SizedBox(width: 8),
                Text('Browse Products'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCartItems(cartProvider),
                SizedBox(height: 24),
                _buildEventDetails(cartProvider),
              ],
            ),
          ),
        ),
        _buildCheckoutSection(cartProvider),
      ],
    );
  }

  Widget _buildTabletLayout(CartProvider cartProvider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCartItems(cartProvider),
                SizedBox(height: 32),
                _buildEventDetails(cartProvider),
              ],
            ),
          ),
        ),
        SizedBox(width: 350, child: _buildCheckoutSidebar(cartProvider)),
      ],
    );
  }

  Widget _buildDesktopLayout(CartProvider cartProvider) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartItems(cartProvider),
                    SizedBox(height: 48),
                    _buildEventDetails(cartProvider),
                  ],
                ),
              ),
            ),
            SizedBox(width: 400, child: _buildCheckoutSidebar(cartProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cart Items (${cartProvider.itemCount})',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _showClearCartDialog(cartProvider),
              child: Text('Clear All'),
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: cartProvider.cartItems.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final cartItem = cartProvider.cartItems[index];
            return CartItemCard(
              cartItem: cartItem,
              onQuantityChanged: (quantity) {
                cartProvider.updateItemQuantity(cartItem.productId, quantity);
              },
              onRemove: () {
                cartProvider.removeItem(cartItem.productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${cartItem.product.name} removed from cart'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventDetails(CartProvider cartProvider) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Event Date
            InkWell(
              onTap: () => _selectEventDate(cartProvider),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _selectedEventDate != null
                                ? '${_selectedEventDate!.day}/${_selectedEventDate!.month}/${_selectedEventDate!.year}'
                                : 'Select event date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedEventDate != null ? Colors.black : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Event Location
            TextField(
              controller: _eventLocationController,
              decoration: InputDecoration(
                labelText: 'Event Location *',
                hintText: 'Enter event location',
                prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              onChanged: (value) {
                cartProvider.setEventDetails(eventLocation: value);
              },
            ),
            SizedBox(height: 16),

            // Event Notes
            TextField(
              controller: _eventNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any special requirements or notes...',
                prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              onChanged: (value) {
                cartProvider.setEventDetails(eventNotes: value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriceSummary(cartProvider),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              onPressed: cartProvider.canCheckout() ? () => _proceedToCheckout(cartProvider) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.payment), SizedBox(width: 8), Text('Proceed to Checkout')],
              ),
            ),
          ),
          if (!cartProvider.canCheckout())
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please fill in event date and location',
                style: TextStyle(color: AppColors.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSidebar(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(left: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          _buildPriceSummary(cartProvider),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              onPressed: cartProvider.canCheckout() ? () => _proceedToCheckout(cartProvider) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.payment), SizedBox(width: 8), Text('Proceed to Checkout')],
              ),
            ),
          ),
          if (!cartProvider.canCheckout())
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Please fill in event date and location',
                style: TextStyle(color: AppColors.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 24),
          _buildSecurityBadge(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cartProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal (${cartProvider.totalQuantity} items)'),
            Text('GH₵${cartProvider.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery', style: TextStyle(color: Colors.grey[600])),
            Text('Calculated at checkout', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'GH₵${cartProvider.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.success, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Secure checkout with SSL encryption',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectEventDate(CartProvider cartProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedEventDate) {
      setState(() {
        _selectedEventDate = picked;
      });
      cartProvider.setEventDetails(eventDate: picked);
    }
  }

  void _showClearCartDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart'),
        content: Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cart cleared'), backgroundColor: AppColors.success),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(CartProvider cartProvider) {
    cartProvider.setEventDetails(
      eventLocation: _eventLocationController.text,
      eventNotes: _eventNotesController.text,
    );
    context.go('/checkout');
  }
}

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                color: Colors.grey[200],
              ),
              child: cartItem.product.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: CachedNetworkImage(
                        imageUrl: cartItem.product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Icon(Icons.image_outlined, color: Colors.grey);
                        },
                      ),
                    )
                  : Icon(Icons.image_outlined, color: Colors.grey),
            ),
            SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'GH₵${cartItem.product.price.toStringAsFixed(2)} each',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total: GH₵${cartItem.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: cartItem.quantity > 1
                          ? () => onQuantityChanged(cartItem.quantity - 1)
                          : null,
                      icon: Icon(Icons.remove),
                      iconSize: 16,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        minimumSize: Size(32, 32),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        cartItem.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: cartItem.quantity < cartItem.product.quantity
                          ? () => onQuantityChanged(cartItem.quantity + 1)
                          : null,
                      icon: Icon(Icons.add),
                      iconSize: 16,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(32, 32),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: onRemove,
                  child: Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
