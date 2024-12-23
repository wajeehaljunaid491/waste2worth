import 'package:flutter/material.dart';

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points History'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: const Text('Points History Data'),
      ),
    );
  }
}
