import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/auth_wrapper.dart';
import 'providers/app_provider.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdService.instance.initialize();

  // Initialize Notifications
  await NotificationService.instance.initialize();

  // Initialize Connectivity Service
  await ConnectivityService().initialize();

  runApp(const LearnEarnApp());
}

class LearnEarnApp extends StatelessWidget {
  const LearnEarnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'Learn & Earn',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/main': (context) => const MainNavigation(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
