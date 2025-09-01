import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/order_sucess_screen.dart';
import 'screens/order_status_screen.dart';
import 'screens/last_order_screen.dart';

import 'models/cart_model.dart';
import 'models/order_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => OrderModel()),
      ],
      child: const TableTapApp(),
    ),
  );
}
class TableTapApp extends StatelessWidget {
  const TableTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final tableNumberStr = uri.queryParameters['table_number'];

    // If table_number exists in URL, navigate to MenuScreen with menuUrl
    if (tableNumberStr != null) {
      final menuUrl = "http://192.168.0.244:5000/menu?table_number=$tableNumberStr";

      return MaterialApp(
        title: 'TableTap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: MenuScreen(menuUrl: menuUrl),
        onGenerateRoute: _onGenerateRoute,
      );
    }

    // Default app with initial route /home
    return MaterialApp(
      title: 'TableTap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      initialRoute: '/home',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/menu') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => MenuScreen(menuUrl: args['menuUrl']),
      );
    }
    // other routes as before...
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case '/scan':
        return MaterialPageRoute(builder: (context) => const ScanQRScreen());
      case '/cart':
        return MaterialPageRoute(builder: (context) => const CartScreen());
      case '/order-summary':
        return MaterialPageRoute(builder: (context) => const OrderSummaryScreen());
      case '/order-success':
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('orderId')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Order ID missing!")),
              ),
            );
          }
          final int orderId = args['orderId'] is int
              ? args['orderId']
              : int.tryParse(args['orderId'].toString()) ?? 0;
          return MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: orderId),
          );
        }
      case '/order-status':
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('orderId')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Order ID missing!")),
              ),
            );
          }
          final int orderId = args['orderId'] is int
              ? args['orderId']
              : int.tryParse(args['orderId'].toString()) ?? 0;
          return MaterialPageRoute(
            builder: (_) => OrderStatusScreen(orderId: orderId),
          );
        }
      case '/last-order':
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('tableNumber')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Table number missing!")),
              ),
            );
          }
          final int tableNumber = args['tableNumber'] is int
              ? args['tableNumber']
              : int.tryParse(args['tableNumber'].toString()) ?? 0;
          return MaterialPageRoute(
            builder: (_) => LastOrderScreen(tableNumber: tableNumber),
          );
        }
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
    }
  }
}
