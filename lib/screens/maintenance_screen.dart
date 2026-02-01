import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Under Maintenance', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('We will be back shortly.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
