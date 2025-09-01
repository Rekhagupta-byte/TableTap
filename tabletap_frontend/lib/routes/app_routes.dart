import 'package:flutter/material.dart';
import 'package:tabletap_frontend/screens/auth/login_screen.dart';
import 'package:tabletap_frontend/screens/auth/email_input_screen.dart';
import 'package:tabletap_frontend/screens/auth/otp_verify_screen.dart';
import 'package:tabletap_frontend/screens/owner/owner_home_screen.dart';
import 'package:tabletap_frontend/screens/owner/add_menu_item_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/signupEmail': (context) => const EmailInputScreen(),
  '/verifyOtp': (context) =>
      const OtpVerifyScreen(email: ''), // Replace dynamically when navigating

  '/ownerHome': (context) => const OwnerHomeScreen(),
  '/addMenuItem': (context) => AddMenuItemScreen(),
};
