import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: false,
            onChanged: (value) {
              // Implement dark mode toggle
            },
          ),
          ListTile(
            title: Text('Change Password'),
            onTap: () {
              // Navigate to change password screen
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              // Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}
