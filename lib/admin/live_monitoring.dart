import 'package:flutter/material.dart';

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.monitor_heart, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text('Live monitoring system coming soon.',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
