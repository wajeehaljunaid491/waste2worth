import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:waste2worth/scenes/welcome_scene.dart'; // Welcome Screen
import 'package:waste2worth/scenes/home_scene.dart'; // Home Screen
import 'scenes/shop.dart'; // Shop Screen
import 'scenes/settings.dart'; // Settings Screen
import 'package:waste2worth/admin/dashboard.dart'; // Admin Dashboard Screen
import 'package:waste2worth/scenes/sellrequest.dart'; // Sell Request Screen
import 'firebase_options.dart'; // Import Firebase options (from generated file)
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use generated Firebase options
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(Waste2WorthApp());
}

class Waste2WorthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste2Worth',
      theme: ThemeData(
        primarySwatch: Colors.green, // Green color for eco-friendly theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorScreen();
          } else if (snapshot.hasData) {
            // Check if the logged-in user is an admin using Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return ErrorScreen(); // Handle Firestore access error
                } else {
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  bool isAdmin = userData['isAdmin'] ?? false;
                  return isAdmin
                      ? DashboardScreen(uid: snapshot.data!.uid) // Admin dashboard
                      : HomeScene(uid: snapshot.data!.uid); // Normal user home
                }
              },
            );
          } else {
            return WelcomeScreen(); // No user logged in
          }
        },
      ),
      initialRoute: '/', // Start with the WelcomeScreen or LoginScreen
      routes: {
        '/home': (context) => HomeScene(uid: '',),
        '/shop': (context) => ShopScene(),
        '/settings': (context) => SettingsScene(),
        '/dashboard': (context) => DashboardScreen(uid: '',), // Admin dashboard
        '/sellrequest': (context) => SellRequest(),
      },
      debugShowCheckedModeBanner: false, // Hide debug banner in app
    );
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Error")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text('Error initializing Firebase.',
                style: TextStyle(fontSize: 20, color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
