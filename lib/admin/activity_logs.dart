import 'package:flutter/material.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: Text('Activity #${index + 1}'),
              subtitle: const Text('Action: User logged in'),
              trailing: Text('Today', style: TextStyle(color: Colors.grey[600])),
            ),
          );
        },
      ),
    );
  }
}
