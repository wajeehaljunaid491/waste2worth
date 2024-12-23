import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2worth/scenes/home_scene.dart';
import 'package:waste2worth/scenes/shop.dart';
import 'package:waste2worth/scenes/profile.dart';

class SellRequest extends StatefulWidget {
  const SellRequest({Key? key}) : super(key: key);

  @override
  _SellRequestState createState() => _SellRequestState();
}

class _SellRequestState extends State<SellRequest> {
  List<Uint8List> imageBytesList = [];
  String userAddress = '';
  final TextEditingController addressController = TextEditingController();

  final List<WasteCategory> wasteCategories = [
    WasteCategory(name: 'Cardboard', image: 'assets/images/cardboard.png', weight: 0, pricePerKg: 10.0),
    WasteCategory(name: 'Paper', image: 'assets/images/paper.png', weight: 0, pricePerKg: 5.0),
    WasteCategory(name: 'Glass', image: 'assets/images/glass.png', weight: 0, pricePerKg: 7.0),
    WasteCategory(name: 'Metal', image: 'assets/images/metal.png', weight: 0, pricePerKg: 20.0),
    WasteCategory(name: 'Plastic', image: 'assets/images/plastic.png', weight: 0, pricePerKg: 8.0),
    WasteCategory(name: 'Other', image: 'assets/images/other.png', weight: 0, pricePerKg: 12.0),
  ];

  Future<void> pickImages() async {
    try {
      final List<dynamic>? mediaData = await ImagePickerWeb.getMultiImages(outputType: ImageType.bytes);
      if (mediaData != null) {
        setState(() {
          imageBytesList = mediaData.cast<Uint8List>();
        });
      } else {
        print('No images selected');
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  double get totalCoins {
    return wasteCategories.fold(0.0, (total, category) {
      return total + (category.weight * category.pricePerKg);
    });
  }

  Future<void> submitRequest() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showErrorDialog(message: "You must be logged in to submit a request.");
      return;
    }

    if (userAddress.isEmpty && addressController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'address': addressController.text,
        });
        setState(() {
          userAddress = addressController.text;
        });
      } catch (e) {
        print('Error updating address: $e');
        showErrorDialog(message: "Failed to save your address. Please try again.");
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('sellrequests').add({
        'userId': user.uid,
        'address': userAddress,
        'totalCoins': totalCoins,
        'wasteCategories': wasteCategories.map((category) => {
          'name': category.name,
          'weight': category.weight,
          'pricePerKg': category.pricePerKg,
        }).toList(),
        'status': 'Under Review',
        'timestamp': FieldValue.serverTimestamp(),
        'images': imageBytesList.map((image) => image.toString()).toList(),
      });

      showRequestSuccessDialog();
    } catch (e) {
      print("Error submitting request: $e");
      showErrorDialog(message: "Failed to submit request. Please try again.");
    }
  }

  void showErrorDialog({required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showRequestSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your request is under review.'),
              const SizedBox(height: 16),
              Image.asset('assets/images/rv11.png', height: 100, width: 100),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['address'] != null) {
          setState(() {
            userAddress = userDoc['address'];
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF90B290),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pick Up Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImages,
        tooltip: 'Pick Images',
        backgroundColor: Color(0xFF90B290),
        child: Image.asset('assets/images/camra.png', width: 40, height: 40),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon('assets/images/home.png', HomeScene()),
              _buildNavIcon('assets/images/shop.png', ShopScene()),
              _buildNavIcon('assets/images/rq1.png', SellRequest()),
              _buildNavIcon('assets/images/profile.png', ProfileScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAddressCard(),
        const SizedBox(height: 20),
        ...wasteCategories.map((category) => _buildMaterialCard(context, category)).toList(),
        const SizedBox(height: 20),
        if (imageBytesList.isNotEmpty) _buildImagePreview(),
        Text(
          'Total: ${totalCoins.toStringAsFixed(2)} Coins',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF90B290)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF90B290),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildNavIcon(String asset, Widget targetScene) {
    return IconButton(
      icon: Image.asset(asset, height: 50),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScene));
      },
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/pin.png', width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userAddress.isNotEmpty ? userAddress : 'Enter Address Here',
              style: TextStyle(fontSize: 14, color: userAddress.isEmpty ? Colors.grey : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              if (userAddress.isEmpty) {
                setState(() {
                  userAddress = addressController.text;
                });
              }
            },
            child: const Text(
              'Change',
              style: TextStyle(color: Color(0xFF90B290), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, WasteCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(category.image, height: 60, width: 60),
          Text(
            category.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            '${category.weight} Kg',
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: Image.asset('assets/images/less.png', width: 24, height: 24),
                onPressed: () {
                  if (category.weight > 0) {
                    setState(() {
                      category.weight--;
                    });
                  }
                },
              ),
              IconButton(
                icon: Image.asset('assets/images/more.png', width: 24, height: 24),
                onPressed: () {
                  setState(() {
                    category.weight++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('Uploaded Images:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 10),
    SizedBox(
    height: 120,
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: imageBytesList.length,
    itemBuilder: (context, index) {
    return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        imageBytesList[index],
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    ),
    );
    },
    ),
    ),
        ],
    );
  }
}

class WasteCategory {
  String name;
  String image;
  double weight;
  double pricePerKg;

  WasteCategory({
    required this.name,
    required this.image,
    required this.weight,
    required this.pricePerKg,
  });
}

