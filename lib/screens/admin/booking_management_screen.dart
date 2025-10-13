import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/booking_item.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.loadAllBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Booking Management',
        showCart: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
              bookingProvider.loadAllBookings();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Completed'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                if (bookingProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (bookingProvider.errorMessage != null) {
                  return _buildErrorView(bookingProvider);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(bookingProvider.bookings),
                    _buildBookingList(bookingProvider.getBookingsByStatus(BookingStatus.pending)),
                    _buildBookingList(bookingProvider.getBookingsByStatus(BookingStatus.approved)),
                    _buildBookingList(bookingProvider.getBookingsByStatus(BookingStatus.completed)),
                    _buildBookingList(bookingProvider.getBookingsByStatus(BookingStatus.rejected)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No bookings found'),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(bookings),
      tablet: _buildTabletList(bookings),
      desktop: _buildDesktopTable(bookings),
    );
  }

  Widget _buildMobileList(List<BookingModel> bookings) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildTabletList(List<BookingModel> bookings) {
    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildDesktopTable(List<BookingModel> bookings) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Card(
          elevation: AppConstants.cardElevation,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: bookings.map((booking) {
                return DataRow(
                  cells: [
                    DataCell(Text('${booking.id.substring(0, 8)}...')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(booking.customerName),
                          Text(
                            booking.customerEmail,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(DateFormat('MMM dd, yyyy').format(booking.eventDate))),
                    DataCell(Text('${booking.items.length} items')),
                    DataCell(Text('GH₵ ${booking.totalAmount.toStringAsFixed(2)}')),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: booking.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: booking.statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          booking.statusDisplayName,
                          style: TextStyle(
                            color: booking.statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(_buildActionButtons(booking)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: booking.statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: TextStyle(
                      color: booking.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(child: Text(booking.customerName)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(child: Text(booking.customerEmail)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(DateFormat('MMM dd, yyyy').format(booking.eventDate)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(child: Text(booking.eventLocation)),
              ],
            ),
            SizedBox(height: 8),
            Text('Items (${booking.items.length}):'),
            ...booking.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text('• ${item.productName} x${item.quantity}'),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: GH₵ ${booking.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                _buildActionButtons(booking),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showBookingDetails(booking),
          icon: Icon(Icons.visibility, size: 20),
          tooltip: 'View Details',
        ),
        if (booking.status == BookingStatus.pending) ...[
          IconButton(
            onPressed: () => _updateBookingStatus(booking.id, BookingStatus.approved),
            icon: Icon(Icons.check, color: AppColors.success, size: 20),
            tooltip: 'Approve',
          ),
          IconButton(
            onPressed: () => _updateBookingStatus(booking.id, BookingStatus.rejected),
            icon: Icon(Icons.close, color: AppColors.error, size: 20),
            tooltip: 'Reject',
          ),
        ],
        if (booking.status == BookingStatus.approved)
          IconButton(
            onPressed: () => _updateBookingStatus(booking.id, BookingStatus.completed),
            icon: Icon(Icons.done_all, color: Colors.blue, size: 20),
            tooltip: 'Mark Complete',
          ),
      ],
    );
  }

  Widget _buildErrorView(BookingProvider bookingProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(bookingProvider.errorMessage!),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () => bookingProvider.loadAllBookings(), child: Text('Retry')),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Booking ID', booking.id),
                _buildDetailRow('Customer', booking.customerName),
                _buildDetailRow('Email', booking.customerEmail),
                _buildDetailRow('Phone', booking.customerPhone),
                _buildDetailRow('Event Date', DateFormat('MMM dd, yyyy').format(booking.eventDate)),
                _buildDetailRow('Event Location', booking.eventLocation),
                _buildDetailRow('Status', booking.statusDisplayName),
                _buildDetailRow(
                  'Created',
                  DateFormat('MMM dd, yyyy HH:mm').format(booking.createdAt),
                ),
                if (booking.notes.isNotEmpty) _buildDetailRow('Notes', booking.notes),
                SizedBox(height: 16),
                Text(
                  'Items:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...booking.items.map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.productName} x${item.quantity}')),
                        Text('GH₵ ${item.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'GH₵ ${booking.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, BookingStatus status) async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.updateBookingStatus(bookingId, status);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
