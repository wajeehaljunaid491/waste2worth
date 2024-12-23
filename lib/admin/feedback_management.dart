import 'package:flutter/material.dart';

class FeedbackManagementScreen extends StatelessWidget {
  const FeedbackManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.feedback, color: Colors.green),
              title: Text('Feedback #${index + 1}'),
              subtitle: const Text('User: John Doe | Rating: 4/5'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Delete feedback
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
