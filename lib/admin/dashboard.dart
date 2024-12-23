import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trade_requests.dart';
import 'user_management.dart';
import 'shop_management.dart';
import 'package:waste2worth/admin/orders_screen.dart';
import 'package:waste2worth/scenes/welcome_screen2.dart';// Import the WelcomeScreen2 (or appropriate screen after logout)

class DashboardScreen extends StatelessWidget {
  final String uid; // Add a final variable to accept the uid

  const DashboardScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Color(0xFF90B290), // Set a consistent theme color
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardCard('Trade Requests', Icons.request_page, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TradeRequestsScreen()));
            }),
            _buildDashboardCard('User Management', Icons.people, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
            }),
            _buildDashboardCard('Shop Management', Icons.shop, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  ShopManagement()));
            }),
            _buildDashboardCard('Orders', Icons.shopping_cart, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  OrdersScreen()));
            }),
          ],
        ),
      ),
    );
  }

  // Widget to build each dashboard card
  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color:Color(0xFF90B290)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build the drawer with navigation options
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF90B290),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Manage your app', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          _buildDrawerItem(context, 'Dashboard', Icons.dashboard, () {
            Navigator.pop(context); // Close the drawer if already on dashboard
          }),
          _buildDrawerItem(context, 'User Management', Icons.people, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
          }),
          _buildDrawerItem(context, 'Trade Requests', Icons.request_page, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TradeRequestsScreen()));
          }),
          _buildDrawerItem(context, 'Shop Management', Icons.shop, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  ShopManagement()));
          }),
          _buildDrawerItem(context, 'Orders', Icons.shopping_cart, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  OrdersScreen()));
          }),
          // Add logout button here
          _buildDrawerItem(context, 'Logout', Icons.exit_to_app, () {
            _logout(context);
          }),
        ],
      ),
    );
  }

  // Helper method to build each drawer item
  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF90B290)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  // Logout method
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid'); // Remove the stored UID
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen2()), // Navigate to WelcomeScreen2 or the appropriate screen
    );
  }
}
