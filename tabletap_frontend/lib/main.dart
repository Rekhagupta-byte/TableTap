import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabletap_frontend/screens/owner/menu_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// Auth & home screens
import 'package:tabletap_frontend/screens/auth/login_screen.dart';
import 'package:tabletap_frontend/screens/auth/email_input_screen.dart';
import 'package:tabletap_frontend/screens/owner/owner_home_screen.dart';
import 'package:tabletap_frontend/screens/staff/staff_home_screen.dart';
import 'package:tabletap_frontend/screens/owner/manage_menu_screen.dart';
import 'package:tabletap_frontend/screens/owner/add_menu_item_screen.dart';
import 'package:tabletap_frontend/screens/owner/manage_orders_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? role = prefs.getString('role');
  String? staffJson = prefs.getString('staffInfo'); // staff info as JSON

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    role: role,
    staffJson: staffJson,
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? role;
  final String? staffJson;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
    this.staffJson,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'table') {
        final tableNumber =
            uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => MenuScreen(tableNumber: tableNumber),
          ),
        );
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;

    if (!widget.isLoggedIn) {
      homeScreen = const LoginScreen();
    } else if (widget.role == 'owner') {
      homeScreen = const OwnerHomeScreen();
    } else if (widget.role == 'staff') {
      if (widget.staffJson != null && widget.staffJson!.isNotEmpty) {
        final Map<String, dynamic> staffInfo = jsonDecode(widget.staffJson!);
        // Force password change if not activated
        if (staffInfo['is_activated'] == 0) {
          homeScreen = LoginScreen(); // or navigate to ChangePasswordScreen
        } else {
          homeScreen = StaffHomeScreen(staff: staffInfo);
        }
      } else {
        homeScreen = const LoginScreen(); // fallback
      }
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'TableTap',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: homeScreen,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signupEmail': (context) => const EmailInputScreen(),
        '/ownerHome': (context) => const OwnerHomeScreen(),
        '/menuManagement': (context) => const ManageMenuScreen(),
        '/addMenuItem': (context) => const AddMenuItemScreen(),
        '/manageOrders': (context) => const ManageOrdersScreen(),
      },
    );
  }
}
