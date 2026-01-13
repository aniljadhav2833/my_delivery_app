import 'package:flutter/material.dart';
import 'package:my_delivery/auth/app_lock.dart';
import 'package:my_delivery/screens/home_screen.dart';
import 'package:my_delivery/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AppLock(child: HomeScreen()),
    );
  }
}
