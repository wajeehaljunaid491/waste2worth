import 'package:flutter/material.dart';

class ShopScreen1 extends StatelessWidget {
  const ShopScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 10, // Replace with dynamic item count
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Image.asset('assets/product_image.png', fit: BoxFit.cover),
                  const SizedBox(height: 10),
                  const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      // Add item to cart or purchase
                    },
                    child: const Text('Buy Now'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
