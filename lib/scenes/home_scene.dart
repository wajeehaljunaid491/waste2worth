import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/Leaderboard.dart';
import 'shop.dart';
import 'settings.dart';
import 'MaterialDetailScene.dart';
import 'profile.dart';
import 'sellrequest.dart';
import 'package:waste2worth/scenes/login_screen.dart';
class HomeScene extends StatefulWidget {
  final String? uid; // UID can be null if retrieved from SharedPreferences

  const HomeScene({Key? key, this.uid}) : super(key: key);

  @override
  _HomeSceneState createState() => _HomeSceneState();
}
class _HomeSceneState extends State<HomeScene> {
  String? userName; // To store the user's name
  double wasteManaged = 0.0; // Initial waste managed value
  double progress = 0.0; // Default progress value
  int coins = 0; // Initial coins value
  final double wasteGoal = 100.0; // Target waste goal
  final List<String> levelImages = [
    'assets/images/level1.png',
    'assets/images/level2.png',
    'assets/images/level3.png',
  ];
  String? uid;

  @override
  void initState() {
    super.initState();
    initializeUID(); // Initialize UID from SharedPreferences or widget
  }

  // Initialize UID from SharedPreferences or use provided widget UID
  Future<void> initializeUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If UID is not in SharedPreferences, save the widget UID
    if (prefs.getString('uid') == null && widget.uid != null) {
      prefs.setString('uid', widget.uid!);
    }

    setState(() {
      uid = prefs.getString('uid');
    });

    if (uid != null) {
      fetchUserData(uid!); // Refresh user data on screen initialization
    }
  }

  // Fetch user data (name, wasteManaged, coins) from Firestore
  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            userName = userDoc['name'];
            wasteManaged = userDoc['wasteManaged'].toDouble();
            coins = userDoc['coins'];
            progress = _calculateProgress(wasteManaged, wasteGoal);
          });

          // Store user data in SharedPreferences for caching
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('name', userDoc['name']);
          prefs.setDouble('wasteManaged', wasteManaged);
          prefs.setInt('coins', coins);
        }
      } else {
        print("No user found for UID: $uid");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Log out and clear stored UID
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  double _calculateProgress(double wasteManaged, double wasteGoal) {
    return wasteManaged >= wasteGoal ? 1.0 : wasteManaged / wasteGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello, ${userName ?? 'Loading...'}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "$coins Coins",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's Recycle",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 137, 188, 132),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMaterialCard(context, "Cardboard", "assets/images/cardboard.png", 36),
                    _buildMaterialCard(context, "Paper", "assets/images/paper.png", 38),
                    _buildMaterialCard(context, "Glass", "assets/images/glass.png", 3),
                    _buildMaterialCard(context, "Metal", "assets/images/metal.png", 68),
                    _buildMaterialCard(context, "Plastic", "assets/images/plastic.png", 18),
                    _buildMaterialCard(context, "Trash", "assets/images/trash.png", 35),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Progress",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    top: BorderSide(
                      color: Color.fromARGB(255, 137, 188, 132),
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Waste Managed: $wasteManaged Kg ",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  color: const Color.fromARGB(255, 137, 188, 132),
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Image.asset(levelImages[_getCurrentLevel()], height: 50),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Leaderboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Leaderboard(),
            ],
          ),
        ),
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
                  onPressed: () {} // No action needed for home icon
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
                    MaterialPageRoute(builder: (context) => const SellRequest()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/profile.png', width: 50, height: 50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, String name, String imagePath, int points) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MaterialDetailScene(name: name, points: points)),
        );
      },
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 80),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("$points points", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentLevel() {
    if (wasteManaged <= 200) {
      return 0;
    } else if (wasteManaged <= 750) {
      return 1;
    } else {
      return 2;
    }
  }
}
