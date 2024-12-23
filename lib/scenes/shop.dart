import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart.dart';  // Import the CartScreen widget
import 'package:waste2worth/scenes/home_scene.dart';
import 'package:waste2worth/scenes/sellrequest.dart';
import 'package:waste2worth/scenes/profile.dart';
class ShopScene extends StatefulWidget {
  @override
  _ShopSceneState createState() => _ShopSceneState();
}

class _ShopSceneState extends State<ShopScene> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  final List<Map<String, dynamic>> cart = [];

  void _checkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in!')),
        );
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found!')),
          );
        }
        return;
      }

      final userData = userDoc.data()!;
      final coins = userData['coins'] ?? 0;
      final address = userData['address'] ?? '';

      double totalPrice = cart.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

      if (coins < totalPrice) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient coins!')),
          );
        }
        return;
      }

      if (address.isEmpty) {
        _promptForAddress();
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      batch.update(FirebaseFirestore.instance.collection('users').doc(user.uid), {
        'coins': coins - totalPrice,
      });

      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      batch.set(orderRef, {
        'uid': user.uid,
        'cart': cart,
        'totalPrice': totalPrice,
        'address': address,
        'orderDate': Timestamp.now(),
        'status': 'Processing',
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout successful!')),
        );
      }

      if (mounted) {
        setState(() {
          cart.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred during checkout. Please try again later.')),
        );
      }
      print('Error: $e');
    }
  }

  void _promptForAddress() async {
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your address'),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(hintText: 'Your address'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String address = addressController.text.trim();
                if (address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Address cannot be empty')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({'address': address});

                Navigator.of(context).pop();
                _checkout();
              },
              child: Text('Save Address'),
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
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for products...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
        )
            : Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen(cart: cart, checkout: _checkout)),
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
        backgroundColor: const Color(0xFF90B290),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shop').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data!.docs;
          final filteredDocs = docs.where((doc) {
            final name = (doc['name'] as String).toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('No items found.'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final item = filteredDocs[index];
              return GestureDetector(
                onTap: () => _showCheckoutDialog(context, item),
                child: Card(
                  elevation: 10.0,
                  shadowColor: Colors.black.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: item['image'] != null
                                  ? MemoryImage(base64Decode(item['image']))
                                  : AssetImage('assets/images/default.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Unnamed Product',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.0),
                              Row(
                                children: [
                                  Icon(Icons.monetization_on, size: 18, color: Color(0xFF90B290)),
                                  SizedBox(width: 4),
                                  Text(
                                    "${(item['price'] as num).toStringAsFixed(0)} Coins",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF90B290),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.0),
                              Text(
                                "Stock: ${(item['stock'] ?? 0).toString()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Image.asset('assets/images/home.png', width: 50, height: 50),
                onPressed: () {
                  // Navigate to the HomeScene
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScene()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/shop.png', width: 50, height: 50),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/images/rq1.png', width: 50, height: 50),

                onPressed: () {
                  // Navigate to the HomeScene
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SellRequest()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/profile.png', width: 50, height: 50),
                onPressed: () {
                  // Navigate to the HomeScene
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, DocumentSnapshot item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add to Cart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                base64Decode(item['image']),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text(item['name'] ?? 'Unnamed Product'),
              Text("${(item['price'] as num).toStringAsFixed(0)} Coins"),
              Text("Stock: ${(item['stock'] ?? 0).toString()}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cart.add({
                    'name': item['name'],
                    'price': item['price'],
                    'image': item['image'],
                    'quantity': 1,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }
}
