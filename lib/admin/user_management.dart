import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Base64 decoding

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  // Reference to the 'users' collection in Firestore
  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('users').orderBy('name').snapshots();
  }

  // Function to delete a user
  Future<void> deleteUser(String uid, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  // Function to edit a user (navigate to edit screen)
  void editUser(BuildContext context, String uid, Map<String, dynamic> userData) {
    // Implement navigation to edit user screen
    // Example:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserScreen(uid: uid, userData: userData)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsersStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If data is available, build the list
          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              // Extract user data
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              // Safely extract fields with default values
              final String uid = userData['uid'] ?? '';
              final String name = userData['name'] ?? 'No Name';
              final String profileImageBase64 = userData['profileImage'] ?? '';
              final int coins = userData['coins'] ?? 0;
              final int wasteManaged = userData['wasteManaged'] ?? 0;

              // Decode the Base64 image
              final imageBytes = profileImageBase64.isNotEmpty
                  ? base64Decode(profileImageBase64)
                  : null;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : const AssetImage('assets/default_profile_image.png') as ImageProvider,
                  ),
                  title: Text(name),
                  subtitle: Text('Coins: $coins | Waste Managed: $wasteManaged'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        editUser(context, uid, userData);
                      } else if (value == 'delete') {
                        // Confirm before deleting
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete this user?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  deleteUser(uid, context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
