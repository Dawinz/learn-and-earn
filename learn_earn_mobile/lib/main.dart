import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/auth_wrapper.dart';
import 'providers/app_provider.dart';
import 'services/ad_service.dart';
import 'services/notification_service_temp.dart';
import 'services/connectivity_service.dart';
import 'services/version_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/force_update_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Version Service
  await VersionService.instance.initialize();

  // Check for updates
  final versionResult = await VersionService.instance.checkForUpdates();

  // If maintenance mode or force update required, show update screen
  if (versionResult.maintenanceMode || versionResult.forceUpdate) {
    runApp(ForceUpdateApp(versionResult: versionResult));
    return;
  }

  // Initialize other services
  await AdService.instance.initialize();
  await NotificationService.instance.initialize();
  await ConnectivityService().initialize();

  runApp(const LearnEarnApp());
}

class ForceUpdateApp extends StatelessWidget {
  final VersionCheckResult versionResult;

  const ForceUpdateApp({Key? key, required this.versionResult})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn & Earn',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ForceUpdateScreen(versionResult: versionResult),
      debugShowCheckedModeBanner: false,
    );
  }
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
