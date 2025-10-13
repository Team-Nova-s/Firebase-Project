import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showCart;

  const CustomAppBar({super.key, required this.title, this.actions, this.showCart = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, color: Theme.of(context).colorScheme.onPrimary),
          SizedBox(width: 8),
          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      actions: [
        if (showCart) _buildCartIcon(context),
        _buildUserMenu(context),
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Badge.count(
          count: cartProvider.itemCount,
          isLabelVisible: cartProvider.itemCount > 0,
          child: IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.go('/cart'),
          ),
        );
      },
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return PopupMenuButton<String>(
            icon: Icon(Icons.person_outline),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  // TODO: Navigate to profile
                  break;
                case 'bookings':
                  context.go('/bookings');
                  break;
                case 'admin':
                  if (authProvider.isAdmin) {
                    context.go('/admin');
                  }
                  break;
                case 'logout':
                  await authProvider.signOut();
                  context.go('/');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [Icon(Icons.person_outline), SizedBox(width: 8), Text('Profile')],
                ),
              ),
              if (authProvider.isCustomer)
                PopupMenuItem(
                  value: 'bookings',
                  child: Row(
                    children: [Icon(Icons.history), SizedBox(width: 8), Text('My Bookings')],
                  ),
                ),
              if (authProvider.isAdmin)
                PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 8),
                      Text('Admin Panel'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Sign Out')]),
              ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Sign In',
                // style: Theme.of(
                //   context,
                // ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
