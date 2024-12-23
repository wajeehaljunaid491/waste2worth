import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ShopManagement extends StatefulWidget {
  @override
  _ShopManagementState createState() => _ShopManagementState();
}

class _ShopManagementState extends State<ShopManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Function to add a new product to the database
  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final newDoc = _firestore.collection('shop').doc(); // Generate a unique document reference
      final productWithId = {
        'id': newDoc.id, // Add the document ID to the product data
        ...product, // Add the rest of the product data
      };
      await newDoc.set(productWithId); // Save the product data along with the document ID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to update an existing product in the database
  Future<void> updateProduct(String id, Map<String, dynamic> updatedProduct) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('shop').doc(id).update(updatedProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to delete a product from the database
  Future<void> deleteProduct(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('shop').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show product form dialog for adding or editing a product
  void showProductForm({String? id, Map<String, dynamic>? product}) {
    final TextEditingController nameController = TextEditingController(text: product?['name']);
    final TextEditingController stockController = TextEditingController(text: product?['stock']?.toString());
    final TextEditingController priceController = TextEditingController(text: product?['price']?.toString());
    Uint8List? selectedImageBytes;

    if (product != null && product['image'] != null) {
      selectedImageBytes = base64Decode(product['image']);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                selectedImageBytes != null
                    ? Image.memory(
                  selectedImageBytes!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
                    : const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setState(() {
                        selectedImageBytes = bytes;
                      });
                    }
                  },
                  child: const Text('Pick Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                if (nameController.text.isEmpty ||
                    stockController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                final productData = {
                  'name': nameController.text,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'image': selectedImageBytes != null ? base64Encode(selectedImageBytes!) : null,
                };

                if (id == null) {
                  addProduct(productData);
                } else {
                  updateProduct(id, productData);
                }
                Navigator.pop(context);
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Management'),
        backgroundColor: const Color(0xFF90B290),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('shop').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Products Found'));
          }

          final products = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageBytes = product['image'] != null
                  ? base64Decode(product['image'])
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ListTile(
                  leading: imageBytes != null
                      ? Image.memory(
                    imageBytes,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image),
                  title: Text(
                    product['name'] ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Stock: ${product['stock']} | Price: \$${product['price']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF90B290)),
                        onPressed: () {
                          showProductForm(id: product['id'], product: product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteProduct(product['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductForm(),
        backgroundColor: const Color(0xFF90B290),
        child: const Icon(Icons.add),
      ),
    );
  }
}
