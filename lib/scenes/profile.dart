import 'dart:convert'; // For Base64 decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'notification_screen.dart';
import 'shared_components.dart';
import 'home_scene.dart'; // Import for HomeScene
import 'package:waste2worth/scenes/edit_profile_screen.dart';
import 'package:waste2worth/scenes/shop.dart';
import 'package:waste2worth/scenes/sellrequest.dart';
import 'package:waste2worth/scenes/welcome_screen2.dart'; // Import your WelcomePage2

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? uid;
  String? userName;
  String? email;
  String? profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadUID();
  }

  // Load UID from SharedPreferences and fetch user data from Firestore
  Future<void> _loadUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid');
    });

    if (uid != null) {
      await _fetchUserData();
    }
  }

  // Fetch user data from Firestore using the UID
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          email = userDoc['email'];
          profileImageBase64 = userDoc['profileImage']; // Store Base64 string
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Handle Logout: Clear UID and navigate to WelcomeScreen2
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid'); // Remove the stored UID
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF90B290), // Green color theme
        elevation: 4,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Profile image with loading and error handling
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: profileImageBase64 != null
                          ? Image.memory(
                        base64Decode(profileImageBase64!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.account_circle, size: 60),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            email ?? 'Loading...',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF90B290)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Info Section
            const SectionTitle(title: 'Personal Info'),
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Account',
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // Support Section
            const SectionTitle(title: 'Support'),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.policy_outlined,
              title: 'Legal and Policies',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,  // Red color for logout
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50),  // Full width
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom App Bar with navigation icons
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Image.asset('assets/images/home.png', height: 50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScene(uid: uid), // Pass the UID
                    ),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/shop.png', width: 50, height: 50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShopScene()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/rq1.png', width: 50, height: 50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellRequest()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/profile.png', width: 50, height: 50),
                onPressed: () {
                  Navigator.push(
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
}
