import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/booking_item.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        bookingProvider.loadCustomerBookings(authProvider.currentUser!.id);
      }
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
      appBar: CustomAppBar(title: 'My Bookings'),
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
        _buildTabBar(),
        Expanded(child: _buildTabBarView()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(child: _buildTabBarView()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                SelectableText(bookingProvider.errorMessage!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.currentUser != null) {
                      bookingProvider.loadCustomerBookings(authProvider.currentUser!.id);
                    }
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(bookingProvider.customerBookings),
            _buildBookingList(
              bookingProvider.customerBookings
                  .where((b) => b.status == BookingStatus.pending)
                  .toList(),
            ),
            _buildBookingList(
              bookingProvider.customerBookings
                  .where((b) => b.status == BookingStatus.approved)
                  .toList(),
            ),
            _buildBookingList(
              bookingProvider.customerBookings
                  .where((b) => b.status == BookingStatus.completed)
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Your bookings will appear here once you place an order',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: booking.statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            booking.statusDisplayName,
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          'Booking #${booking.id.substring(0, 8)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Event Date: ${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Location: ${booking.eventLocation}',
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          'GH₵${booking.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...booking.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} × ${item.quantity}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Text(
                          'GH₵${item.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                if (booking.notes.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(booking.notes, style: TextStyle(color: Colors.grey[700])),
                ],
                SizedBox(height: 12),
                Text(
                  'Submitted: ${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
