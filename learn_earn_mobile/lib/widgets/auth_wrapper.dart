import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/no_internet_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ConnectivityService())],
      child: Consumer2<AppProvider, ConnectivityService>(
        builder: (context, appProvider, connectivityService, child) {
          // Show no internet screen if offline
          if (!connectivityService.isConnected) {
            return const NoInternetScreen();
          }

          // Show login screen if not authenticated
          if (!appProvider.isAuthenticated) {
            return const LoginScreen();
          }

          // Show main app if authenticated and online
          return const MainNavigation();
        },
      ),
    );
  }
}
