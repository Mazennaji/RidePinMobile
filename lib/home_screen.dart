import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to RidePin!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
