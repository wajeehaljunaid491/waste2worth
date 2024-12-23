import 'package:flutter/material.dart';

class CategoryPointsScreen extends StatelessWidget {
  const CategoryPointsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Cardboard', 'points': '10'},
      {'name': 'Paper', 'points': '5'},
      {'name': 'Glass', 'points': '20'},
      {'name': 'Metal', 'points': '15'},
      {'name': 'Plastic', 'points': '8'},
      {'name': 'Trash', 'points': '2'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Points'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(category['name']!),
              subtitle: Text('Points per kg: ${category['points']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  // Open an edit modal
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
