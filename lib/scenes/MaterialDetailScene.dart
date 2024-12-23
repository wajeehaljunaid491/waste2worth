import 'package:flutter/material.dart';

class MaterialDetailScene extends StatelessWidget {
  final String name;
  final int points;

  MaterialDetailScene({required this.name, required this.points});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Back action
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF8BB97A), // Modern green color for the AppBar
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material image section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/$name.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Material title
            Text(
              "Material: $name",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),

            // Points information
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFFFFC107), // Gold star color
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "$points Points",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Material description
            Text(
              "Recycling $name is a crucial step toward sustainability. By properly recycling $name, you contribute to reducing waste, conserving energy, and reducing pollution. Additionally, recycling $name can save natural resources that would otherwise be used to create new products.",
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),

            // Additional Information section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Why Should We Recycle $name?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8BB97A),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Recycling $name prevents the depletion of natural resources and reduces the energy required for manufacturing. It also cuts down on pollution and ensures a cleaner environment.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Call to Action (Optional)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Action can be added here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8BB97A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Learn More",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
