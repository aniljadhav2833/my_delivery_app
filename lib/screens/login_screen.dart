import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Parcel Tracking App",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ) /*
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text("Login as Vendor"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VendorDashboard()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Login as Delivery Boy"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeliveryEntryScreen(),
                  ),
                );
              },
            ),*/,
          ],
        ),
      ),
    );
  }
}
