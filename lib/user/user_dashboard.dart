import 'package:flutter/material.dart';
import 'package:waste2worth/user/trade_requests.dart'; // Import Trade requests screen
import 'package:waste2worth/user/user_profile.dart'; // Import Profile screen
import 'package:waste2worth/user/shop1.dart'; // Import Shop screen
import 'package:waste2worth/user/points_history.dart'; // Import Points History screen
import 'package:waste2worth/user/notifications_screen.dart'; // Import Notifications screen

class DashboardScreen1 extends StatelessWidget {
  const DashboardScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.green.shade700,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TradeRequestsScreen()),
              );
            }),
            _buildDashboardCard('Profile', Icons.account_circle, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            }),
            _buildDashboardCard('Shop', Icons.shop, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreen1()),
              );
            }),
            _buildDashboardCard('Points History', Icons.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PointsHistoryScreen()),
              );
            }),
            _buildDashboardCard('Notifications', Icons.notifications, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text('Welcome User', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen1()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen1()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Points History'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PointsHistoryScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
