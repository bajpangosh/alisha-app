import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No Internet Connection', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Please check your connection and try again.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
