import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Show login screen if not authenticated
        if (!appProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Show main app if authenticated
        return const MainNavigation();
      },
    );
  }
}
