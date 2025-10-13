import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/responsive_layout.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventLocationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedEventDate;

  @override
  void dispose() {
    _eventLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
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
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedEventDate == null) {
      if (_selectedEventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an event date'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    bool success = await bookingProvider.submitBooking(
      customer: authProvider.currentUser!,
      items: cartProvider.cartItems,
      eventDate: _selectedEventDate!,
      eventLocation: _eventLocationController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (success) {
      cartProvider.clearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: AppColors.success, size: 64),
          title: Text('Booking Submitted!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your booking request has been submitted successfully.'),
              SizedBox(height: 8),
              Text(
                'You will receive an email confirmation shortly.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/bookings');
              },
              child: Text('View Bookings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: Text('Continue Shopping'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Checkout', showCart: false),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/cart');
            });
            return Center(child: CircularProgressIndicator());
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

  Widget _buildMobileLayout(CartProvider cartProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildEventDetailsForm(),
          _buildOrderSummary(cartProvider),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(CartProvider cartProvider) {
    return Row(
      children: [
        Expanded(flex: 2, child: SingleChildScrollView(child: _buildEventDetailsForm())),
        SizedBox(
          width: 400,
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(child: _buildOrderSummary(cartProvider))),
              _buildSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(CartProvider cartProvider) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Row(
          children: [
            Expanded(flex: 2, child: SingleChildScrollView(child: _buildEventDetailsForm())),
            SizedBox(
              width: 450,
              child: Column(
                children: [
                  Expanded(child: SingleChildScrollView(child: _buildOrderSummary(cartProvider))),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailsForm() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Event Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Date *',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: _selectEventDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedEventDate != null
                                ? '${_selectedEventDate!.day}/${_selectedEventDate!.month}/${_selectedEventDate!.year}'
                                : 'Select event date',
                            style: TextStyle(
                              color: _selectedEventDate != null ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Event Location
            CustomTextField(
              controller: _eventLocationController,
              label: 'Event Location *',
              hintText: 'Enter the event venue address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
              validator: Validators.required,
            ),
            SizedBox(height: 20),

            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Special Instructions',
              hintText: 'Any special requirements or notes (optional)',
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // Important Notes
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Your booking request will be reviewed by our team\n'
                    '• You will receive confirmation within 24 hours\n'
                    '• Delivery and pickup times will be coordinated separately\n'
                    '• Payment is due upon delivery',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
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
          SizedBox(height: 16),

          // Items List
          ...cartProvider.cartItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.product.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) {
                                return Icon(Icons.image_outlined, color: Colors.grey);
                              },
                            ),
                          )
                        : Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty: ${item.quantity} × GH₵${item.product.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'GH₵${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            );
          }),

          Divider(height: 24),

          // Summary
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
            children: [Text('Delivery'), Text('TBD')],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoadingButton(
                onPressed: _submitBooking,
                isLoading: bookingProvider.isLoading,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.check), SizedBox(width: 8), Text('Submit Booking Request')],
                ),
              ),
              if (bookingProvider.errorMessage != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookingProvider.errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
