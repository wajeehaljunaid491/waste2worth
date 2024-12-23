// lib/scenes/settings.dart

import 'package:flutter/material.dart';

class SettingsScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Profile Settings"),
              onTap: () {
                // Navigate to profile settings page
              },
            ),
            ListTile(
              title: Text("Notifications"),
              onTap: () {
                // Toggle notifications
              },
            ),
            ListTile(
              title: Text("Privacy Policy"),
              onTap: () {
                // Show privacy policy
              },
            ),
          ],
        ),
      ),
    );
  }
}
