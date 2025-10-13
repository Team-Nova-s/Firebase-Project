import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/widgets/admin/add_product_dialog.dart';
import 'package:papela/widgets/admin/dashboard_card.dart';
import 'package:papela/widgets/admin/recent_bookings_list.dart';
import 'package:papela/widgets/admin/revenue_chart.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/responsive_layout.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      bookingProvider.loadAllBookings();
      productProvider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        showCart: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDashboardData, tooltip: 'Refresh'),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsGrid(crossAxisCount: 2),
          SizedBox(height: 24),
          RecentBookingsList(),
          SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatsGrid(crossAxisCount: 3),
          SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: RecentBookingsList()),
              SizedBox(width: 24),
              Expanded(flex: 1, child: _buildQuickActions()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Column(
          children: [
            _buildStatsGrid(crossAxisCount: 4),
            SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [RevenueChart(), SizedBox(height: 32), RecentBookingsList()],
                  ),
                ),
                SizedBox(width: 32),
                Expanded(flex: 1, child: _buildQuickActions()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid({required int crossAxisCount}) {
    return Consumer2<BookingProvider, ProductProvider>(
      builder: (context, bookingProvider, productProvider, child) {
        final totalBookings = bookingProvider.bookings.length;
        final pendingBookings = bookingProvider.getPendingBookingsCount();
        final totalProducts = productProvider.products.length;
        final monthlyRevenue = bookingProvider.getMonthlyRevenue();

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: 'Total Bookings',
              value: totalBookings.toString(),
              icon: Icons.event,
              color: AppColors.primary,
              onTap: () => context.go('/admin/bookings'),
            ),
            DashboardCard(
              title: 'Pending Bookings',
              value: pendingBookings.toString(),
              icon: Icons.pending,
              color: Colors.orange,
              onTap: () => context.go('/admin/bookings'),
            ),
            DashboardCard(
              title: 'Total Products',
              value: totalProducts.toString(),
              icon: Icons.inventory,
              color: AppColors.secondary,
              onTap: () => context.go('/admin/products'),
            ),
            DashboardCard(
              title: 'Monthly Revenue',
              value: 'GH₵ ${monthlyRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: AppColors.success,
              onTap: () {}, // TODO: Navigate to analytics
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.add,
              label: 'Add Product',
              onPressed: () => _showAddProductDialog(),
            ),
            SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.inventory,
              label: 'Manage Products',
              onPressed: () => context.go('/admin/products'),
            ),
            SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.event,
              label: 'Manage Bookings',
              onPressed: () => context.go('/admin/bookings'),
            ),
            SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.analytics,
              label: 'View Analytics',
              onPressed: () {}, // TODO: Navigate to analytics
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      authProvider.currentUser?.name ?? 'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  selected: GoRouterState.of(context).matchedLocation == '/admin',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.inventory),
                  title: Text('Products'),
                  selected: GoRouterState.of(context).matchedLocation == '/admin/products',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/products');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Bookings'),
                  selected: GoRouterState.of(context).matchedLocation == '/admin/bookings',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/bookings');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Back to Site'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddProductDialog(),
    );
  }
}
