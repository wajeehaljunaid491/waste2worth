import 'dart:typed_data';
import 'package:flutter/material.dart';

// Admin request management page
class AdminRequestPage extends StatefulWidget {
  const AdminRequestPage({Key? key}) : super(key: key);

  @override
  _AdminRequestPageState createState() => _AdminRequestPageState();
}

class _AdminRequestPageState extends State<AdminRequestPage> {
  // Example list of requests to be displayed
  final List<SellRequestData> requests = [
    SellRequestData(
      address: '123 Street Name, City',
      totalCoins: 50.0,
      wasteCategories: [
        WasteCategory(name: 'Cardboard', image: 'assets/images/cardboard.png', weight: 5, pricePerKg: 10.0),
        WasteCategory(name: 'Plastic', image: 'assets/images/plastic.png', weight: 10, pricePerKg: 8.0),
      ],
      imageBytesList: [Uint8List(10)], // Example image data
    ),
    SellRequestData(
      address: '456 Another St, City',
      totalCoins: 80.0,
      wasteCategories: [
        WasteCategory(name: 'Glass', image: 'assets/images/glass.png', weight: 8, pricePerKg: 7.0),
      ],
      imageBytesList: [Uint8List(20)], // Example image data
    ),
  ];

  // Function to approve a request
  void approveRequest(int index) {
    // Handle approval logic
    setState(() {
      // Placeholder logic: print that the request is approved
      print('Approved request at index: $index');
    });
  }

  // Function to reject a request
  void rejectRequest(int index) {
    // Handle rejection logic
    setState(() {
      // Placeholder logic: print that the request is rejected
      print('Rejected request at index: $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF90B290), // Green color for eco-friendly look
        title: const Text('Admin: Manage Requests'),
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return RequestCard(
            request: request,
            onApprove: () => approveRequest(index),
            onReject: () => rejectRequest(index),
          );
        },
      ),
    );
  }
}

// Request card widget to display details of a sell request
class RequestCard extends StatelessWidget {
  final SellRequestData request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${request.address}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Total Coins: ${request.totalCoins.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display the waste categories and weights
            ...request.wasteCategories.map((category) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${category.name}: ${category.weight} Kg', style: TextStyle(fontSize: 14)),
                  Text(
                    '${(category.weight * category.pricePerKg).toStringAsFixed(2)} Coins',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 8),
            // Display the images
            if (request.imageBytesList.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: request.imageBytesList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          request.imageBytesList[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50), // Green color for approve button
                  ),
                  child: const Text('Approve'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB71C1C), // Red color for reject button
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for a SellRequest
class SellRequestData {
  final String address;
  final double totalCoins;
  final List<WasteCategory> wasteCategories;
  final List<Uint8List> imageBytesList;

  SellRequestData({
    required this.address,
    required this.totalCoins,
    required this.wasteCategories,
    required this.imageBytesList,
  });
}

// Waste category model to store details about each category
class WasteCategory {
  final String name;
  final String image;
  final int weight;
  final double pricePerKg;

  WasteCategory({
    required this.name,
    required this.image,
    required this.weight,
    required this.pricePerKg,
  });
}
