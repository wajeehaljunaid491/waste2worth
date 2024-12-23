import 'dart:convert';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function checkout;

  CartScreen({required this.cart, required this.checkout});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice {
    return widget.cart.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,)),
        backgroundColor: Color(0xFF90B290),  // Modern Green
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(
        child: Text(
          'Your cart is empty.',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
      )
          : ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final item = widget.cart[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.15),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(item['image']),
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Price: ${(item['price'] * item['quantity']).toStringAsFixed(0)} Coins",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.grey[700]),
                          onPressed: () {
                            if (item['quantity'] > 1) {
                              setState(() {
                                item['quantity']--;
                              });
                            }
                          },
                        ),
                        Text(
                          '${item['quantity']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.grey[700]),
                          onPressed: () {
                            setState(() {
                              item['quantity']++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    _confirmDelete(context, item, index);
                  },
                ),
              ),
            ),
          );
        },
      ),
      bottomSheet: widget.cart.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ${totalPrice.toStringAsFixed(0)} Coins',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _checkout(context),
              child: Text(
                'Checkout',
                style: TextStyle(color: Colors.white),  // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF90B290),  // Consistent modern green color
                padding: EdgeInsets.symmetric(vertical: 18.0),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(50, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout(BuildContext context) {
    // Assuming checkout is successful:
    widget.checkout();

    // Pop the CartScreen and navigate back to the ShopScreen
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Delete Item', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Text(
            'Are you sure you want to remove ${item['name']} from your cart?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.cart.removeAt(index);
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
