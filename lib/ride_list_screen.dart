import 'package:flutter/material.dart';
import 'ride_service.dart'; // Import the RideService

class RideListScreen extends StatefulWidget {
  @override
  _RideListScreenState createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> {
  List<dynamic> rides = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rideService = RideService();
      final fetchedRides = await rideService.fetchAvailableRides();
      setState(() {
        rides = fetchedRides;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch rides: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Rides')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return ListTile(
                    title: Text(ride['name']),
                    subtitle: Text(ride['description']),
                  );
                },
              ),
    );
  }
}
