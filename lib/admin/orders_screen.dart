import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<OrdersScreen> {
  String filterStatus = 'All'; // Default filter is All
  List<Map<String, dynamic>> orders = []; // Declare orders list to store fetched data

  // Method to filter orders by status
  List<Map<String, dynamic>> get filteredOrders {
    if (filterStatus == 'All') {
      return orders;
    }
    return orders.where((order) => order['status'] == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Orders'),
        backgroundColor:  Color(0xFF90B290),  // Professional green color
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(), // Stream of orders from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Transform Firestore data into a list of maps
          orders = snapshot.data!.docs.map((doc) {
            return {
              'orderId': doc.id,  // Use Firestore document ID as orderId
              'address': doc['address'],
              'cart': List<Map<String, dynamic>>.from(doc['cart']),
              'status': doc['status'],
              'orderDate': doc['orderDate'].toDate().toString(), // Convert Firestore timestamp to DateTime
              'totalPrice': doc['totalPrice'],
              'uid': doc['uid'],
            };
          }).toList();

          return ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      'Order #${order['orderId']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${order['address']}'),
                        Text('Total: \$${order['totalPrice'].toStringAsFixed(2)}'),
                        Text('Date: ${order['orderDate']}'),
                        Text('Status: ${order['status']}'),
                        SizedBox(height: 8),
                        _buildItemsList(order['cart']),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color:  Color(0xFF90B290)),
                      onPressed: () => _updateOrderStatus(order),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Method to build the item list for each order
  Widget _buildItemsList(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map<Widget>((item) {
        return Text(
          '${item['name']} x${item['quantity']} - \$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
          style: TextStyle(fontSize: 14),
        );
      }).toList(),
    );
  }

  // Method to update the order status
  void _updateOrderStatus(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Order Status'),
          content: DropdownButton<String>(
            value: order['status'],
            onChanged: (value) {
              setState(() {
                order['status'] = value!;
              });

              // Update the status in Firestore
              FirebaseFirestore.instance
                  .collection('orders')
                  .doc(order['orderId'])  // Use the Firestore document ID (orderId)
                  .update({'status': value});

              Navigator.of(context).pop();
            },
            items: ['Processing', 'Shipped', 'Delivered']
                .map((status) => DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            ))
                .toList(),
          ),
        );
      },
    );
  }

  // Method to show the filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Orders'),
          content: DropdownButton<String>(
            value: filterStatus,
            onChanged: (value) {
              setState(() {
                filterStatus = value!;
              });
              Navigator.of(context).pop();
            },
            items: ['All', 'Processing', 'Shipped', 'Delivered']
                .map((status) => DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            ))
                .toList(),
          ),
        );
      },
    );
  }
}
