import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/booking_management_screen.dart';
import '../screens/admin/product_management_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/booking_history_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/catalog_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/product_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isAdmin = authProvider.isAdmin;

      // Auth pages - redirect if already authenticated
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        if (isAuthenticated) {
          return isAdmin ? '/admin' : '/';
        }
      }

      // Admin pages - redirect if not admin
      if (state.matchedLocation.startsWith('/admin')) {
        if (!isAuthenticated) return '/login';
        if (!isAdmin) return '/';
      }

      // Customer protected pages
      if (state.matchedLocation == '/cart' ||
          state.matchedLocation == '/checkout' ||
          state.matchedLocation == '/bookings') {
        if (!isAuthenticated) return '/login';
      }

      return null;
    },
    routes: [
      // Public routes
      GoRoute(path: '/', name: 'home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/catalog', name: 'catalog', builder: (context, state) => CatalogScreen()),
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),

      // Auth routes
      GoRoute(path: '/login', name: 'login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => RegisterScreen()),

      // Customer protected routes
      GoRoute(path: '/cart', name: 'cart', builder: (context, state) => CartScreen()),
      GoRoute(path: '/checkout', name: 'checkout', builder: (context, state) => CheckoutScreen()),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => BookingHistoryScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => AdminDashboard(),
        routes: [
          GoRoute(
            path: '/products',
            name: 'admin-products',
            builder: (context, state) => ProductManagementScreen(),
          ),
          GoRoute(
            path: '/bookings',
            name: 'admin-bookings',
            builder: (context, state) => BookingManagementScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('404 - Page Not Found', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/'), child: Text('Go Home')),
          ],
        ),
      ),
    ),
  );
}
