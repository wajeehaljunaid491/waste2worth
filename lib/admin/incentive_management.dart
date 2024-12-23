import 'package:flutter/material.dart';

class IncentiveManagementScreen extends StatelessWidget {
  const IncentiveManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incentive Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new incentive
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: Text('Incentive #${index + 1}'),
              subtitle: const Text('Description: Special discount'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  // Edit incentive
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
