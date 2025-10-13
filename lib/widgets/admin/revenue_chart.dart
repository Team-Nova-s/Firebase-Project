import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/booking_item.dart';
import 'package:papela/models/booking_model.dart';
import 'package:papela/providers/booking_provider.dart';
import 'package:provider/provider.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  'Revenue Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Last 6 Months',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final chartData = _generateChartData(bookingProvider.bookings);

                  if (chartData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'No revenue data available',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildBarChart(context, chartData);
                },
              ),
            ),
            SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  List<ChartData> _generateChartData(List<BookingModel> bookings) {
    final now = DateTime.now();
    final chartData = <ChartData>[];

    // Generate data for last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthlyRevenue = bookings
          .where(
            (booking) =>
                booking.status == BookingStatus.completed &&
                booking.createdAt.isAfter(month.subtract(Duration(days: 1))) &&
                booking.createdAt.isBefore(nextMonth),
          )
          .fold(0.0, (sum, booking) => sum + booking.totalAmount);

      chartData.add(
        ChartData(month: _getMonthName(month.month), revenue: monthlyRevenue, fullDate: month),
      );
    }

    return chartData;
  }

  Widget _buildBarChart(BuildContext context, List<ChartData> data) {
    final maxRevenue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((chartData) {
        final heightRatio = maxRevenue > 0 ? chartData.revenue / maxRevenue : 0.0;
        final barHeight = (heightRatio * 150).clamp(4.0, 150.0);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Revenue amount
                if (chartData.revenue > 0)
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'GH₵${chartData.revenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // Bar
                AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  height: barHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // Month label
                Text(
                  chartData.month,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final totalRevenue = bookingProvider.getTotalRevenue();
        final monthlyRevenue = bookingProvider.getMonthlyRevenue();

        return Row(
          children: [
            Expanded(
              child: _buildLegendItem(
                context,
                'Total Revenue',
                'GH₵${totalRevenue.toStringAsFixed(2)}',
                AppColors.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildLegendItem(
                context,
                'This Month',
                'GH₵${monthlyRevenue.toStringAsFixed(2)}',
                AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class ChartData {
  final String month;
  final double revenue;
  final DateTime fullDate;

  ChartData({required this.month, required this.revenue, required this.fullDate});
}
