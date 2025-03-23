import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the LoginScreen
import 'ride_service.dart'; // Import the RideService
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'local_storage_service.dart'; // Import the LocalStorageService
import 'payment_service.dart'; // Import the PaymentService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => RideService()),
        Provider(create: (_) => PaymentService()),
        Provider(create: (_) => LocalStorageService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RidePin',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
