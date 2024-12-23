import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Import for Base64 decoding
import 'dart:typed_data'; // Import for Uint8List

class Leaderboard extends StatelessWidget {
  // Fetch users from Firestore, including Base64-decoded images
  Future<List<User>> fetchUsersFromDatabase() async {
    List<User> users = [];
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      for (var doc in snapshot.docs) {
        if (doc['name'] != null && doc['wasteManaged'] != null) {
          Uint8List? imageBytes;
          if (doc['profileImage'] != null) {
            imageBytes = base64Decode(doc['profileImage']);
          }

          users.add(User(
            name: doc['name'],
            wasteManaged: doc['wasteManaged'],
            imageBytes: imageBytes,
          ));
        } else {
          print('Missing data for user: ${doc.id}');
        }
      }

      // Sort users in descending order based on wasteManaged
      users.sort((a, b) => b.wasteManaged.compareTo(a.wasteManaged));
    } catch (e) {
      print('Error fetching users: $e');
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: fetchUsersFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users available.'));
        }

        List<User> users = snapshot.data!;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTopThree(users),
              _buildRemainingList(users),
            ],
          ),
        );
      },
    );
  }

  // Build the top 3 users
  Widget _buildTopThree(List<User> users) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Colors.white],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopUser(users[1], 2),
          _buildTopUser(users[0], 1, isFirst: true),
          _buildTopUser(users[2], 3),
        ],
      ),
    );
  }

  Widget _buildTopUser(User user, int position, {bool isFirst = false}) {
    double size = isFirst ? 100 : 80;
    Color bgColor = isFirst ? Color(0xFF4CAF50) : Color(0xFF81C784);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: bgColor, width: 4),
              ),
              child: ClipOval(
                child: user.imageBytes != null
                    ? Image.memory(
                  user.imageBytes!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.person,
                  size: size / 2,
                  color: Colors.grey,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  position.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          user.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          '${user.wasteManaged} kg',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRemainingList(List<User> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: users.length - 3,
      itemBuilder: (context, index) {
        final user = users[index + 3];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: user.name == "You" ? Color(0xFFE8F5E9) : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Text(
                  '${index + 4}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 16),
              ClipOval(
                child: user.imageBytes != null
                    ? Image.memory(
                  user.imageBytes!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${user.wasteManaged} kg',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Updated User class
class User {
  final String name;
  final int wasteManaged;
  final Uint8List? imageBytes; // Image stored as bytes

  User({required this.name, required this.wasteManaged, this.imageBytes});
}
