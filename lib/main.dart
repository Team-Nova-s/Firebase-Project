import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:papela/providers/auth_provider.dart';
import 'package:papela/providers/booking_provider.dart';
import 'package:papela/providers/cart_provider.dart';
import 'package:papela/providers/product_provider.dart';
import 'package:papela/providers/theme_provider.dart';
import 'package:papela/router/app_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'Firebase_API_Key',
      authDomain: 'Firebase_Auth_Domain',
      projectId: 'Firebase_Project_ID',
      storageBucket: 'Firebase_Storage_Bucket',
      messagingSenderId: 'Firebase_Messaging_Sender_ID',
      appId: 'Firebase_App_ID',
      measurementId: 'Firebase_Measurement_ID',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Papela Event Rentals',
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
