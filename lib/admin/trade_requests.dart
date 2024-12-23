import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TradeRequestsScreen extends StatefulWidget {
  const TradeRequestsScreen({Key? key}) : super(key: key);

  @override
  _TradeRequestsScreenState createState() => _TradeRequestsScreenState();
}

class _TradeRequestsScreenState extends State<TradeRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Removed the admin check since all authenticated users can approve or reject requests
  Future<bool> checkIfAdmin() async {
    // Simply return true as all authenticated users can approve or reject requests
    return true;
  }

  // Function to approve the request and add coins to the user's account
  Future<void> approveRequest(String requestId) async {
    try {
      // Fetch request data
      DocumentSnapshot requestSnapshot = await _firestore.collection('sellrequests').doc(requestId).get();

      if (!requestSnapshot.exists) {
        showErrorDialog(message: "Request not found.");
        return;
      }

      Map<String, dynamic> requestData = requestSnapshot.data() as Map<String, dynamic>;
      String userId = requestData['userId'];
      double totalCoins = requestData['totalCoins']?.toDouble() ?? 0;

      // Calculate totalKg dynamically
      List<dynamic> wasteCategories = requestData['wasteCategories'] ?? [];
      double totalKg = wasteCategories.fold<double>(
        0,
            (sum, category) => sum + (category['weight']?.toDouble() ?? 0),
      );

      // Fetch the user document to update their data
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          showErrorDialog(message: "User not found.");
          return;
        }

        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData == null) {
          showErrorDialog(message: "User data not available.");
          return;
        }

        double userCoins = userData['coins']?.toDouble() ?? 0;
        double wasteManaged = userData['wasteManaged']?.toDouble() ?? 0;

        // Add the totalCoins and totalKg to the respective fields
        double newCoins = userCoins + totalCoins;
        double newWasteManaged = wasteManaged + totalKg;

        // Update the user's data in the transaction
        transaction.update(userRef, {
          'coins': newCoins,
          'wasteManaged': newWasteManaged,
        });
      });

      // Delete the request after updating the user's data
      await _firestore.collection('sellrequests').doc(requestId).delete();

      showSuccessDialog(message: "Request approved and deleted successfully.");
    } catch (e) {
      print("Error processing request: $e");
      showErrorDialog(message: "Failed to process request. Error: $e");
    }
  }

  // Function to show an error dialog
  void showErrorDialog({required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to show a success dialog
  void showSuccessDialog({required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success', style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Function to build a request card widget
  Widget _buildRequestCard(DocumentSnapshot request) {
    final requestId = request.id;
    final requestData = request.data() as Map<String, dynamic>;
    final totalCoins = requestData['totalCoins'];
    final userAddress = requestData['address'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address: $userAddress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Total Coins: \$${totalCoins.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => approveRequest(requestId), // Approve request
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green for approve
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Approve', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await _firestore.collection('sellrequests').doc(requestId).delete();
                  showSuccessDialog(message: "Request rejected and deleted.");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red for reject
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reject', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.data!) {
          return const Center(child: Text('You do not have admin access.'));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF90B290),
            elevation: 0,
            title: const Text('Request Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('sellrequests').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No requests found.'));
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(requests[index]);
                },
              );
            },
          ),
        );
      },
    );
  }
}
