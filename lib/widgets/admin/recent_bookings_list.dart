import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papela/constants/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/booking_provider.dart';

class RecentBookingsList extends StatelessWidget {
  const RecentBookingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Bookings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                final recentBookings = bookingProvider.bookings.take(5).toList();

                if (recentBookings.isEmpty) {
                  return Center(
                    child: Padding(padding: EdgeInsets.all(32), child: Text('No recent bookings')),
                  );
                }

                return Column(
                  children: recentBookings.map((booking) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: booking.statusColor.withValues(alpha: 0.1),
                        child: Icon(Icons.event, color: booking.statusColor, size: 20),
                      ),
                      title: Text(booking.customerName),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(booking.eventDate)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GH₵ ${booking.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: booking.statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.statusDisplayName,
                              style: TextStyle(fontSize: 10, color: booking.statusColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
