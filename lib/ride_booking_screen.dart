import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import 'api_service.dart';

const String _googleMapsApiKey = 'YOUR_ACTUAL_API_KEY';

class RideBookingScreen extends StatefulWidget {
  @override
  _RideBookingScreenState createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  late GoogleMapController _mapController;

  LatLng? _currentPosition;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final PolylinePoints _polylinePoints = PolylinePoints();

  bool _isLoading = false;
  bool _rideBooked = false;
  String _rideStatus = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _pickupLocation = _currentPosition;
        _updateMarkers();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    }

    if (_pickupLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: _pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: 'Pickup Point'),
        ),
      );
    }

    if (_dropoffLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('dropoff'),
          position: _dropoffLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    }

    if (_pickupLocation != null && _dropoffLocation != null) {
      _getRouteDirections();
    }
  }

  Future<void> _getRouteDirections() async {
    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        _googleMapsApiKey,
        PointLatLng(_pickupLocation!.latitude, _pickupLocation!.longitude),
        PointLatLng(_dropoffLocation!.latitude, _dropoffLocation!.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates =
            result.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
          _animateToBounds();
        });
      }
    } catch (e) {
      print('Error drawing route: $e');
    }
  }

  void _animateToBounds() {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(_pickupLocation!.latitude, _dropoffLocation!.latitude),
        min(_pickupLocation!.longitude, _dropoffLocation!.longitude),
      ),
      northeast: LatLng(
        max(_pickupLocation!.latitude, _dropoffLocation!.latitude),
        max(_pickupLocation!.longitude, _dropoffLocation!.longitude),
      ),
    );

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _bookRide() async {
    if (_pickupLocation == null || _dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select pickup and dropoff locations')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post('rides', {
        'pickup_lat': _pickupLocation!.latitude,
        'pickup_lng': _pickupLocation!.longitude,
        'dropoff_lat': _dropoffLocation!.latitude,
        'dropoff_lng': _dropoffLocation!.longitude,
      });

      setState(() {
        _rideBooked = true;
        _rideStatus = 'Driver assigned';
      });

      _listenForRideUpdates(response['ride_id']);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to book ride: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _listenForRideUpdates(String rideId) {
    // Implement WebSocket/Laravel Echo listener
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book a Ride')),
      body: Column(
        children: [
          Expanded(
            child:
                _currentPosition == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition ?? LatLng(0, 0),
                        zoom: 14,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      onTap: (latLng) {
                        if (!_rideBooked) {
                          setState(() {
                            if (_pickupLocation == null ||
                                _pickupLocation == _currentPosition) {
                              _pickupLocation = latLng;
                              _pickupController.text =
                                  '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
                            } else {
                              _dropoffLocation = latLng;
                              _dropoffController.text =
                                  '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
                            }
                            _updateMarkers();
                          });
                        }
                      },
                    ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    prefixIcon: Icon(Icons.location_on, color: Colors.green),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    labelText: 'Dropoff Location',
                    prefixIcon: Icon(Icons.flag, color: Colors.red),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                if (_rideBooked)
                  Column(
                    children: [
                      Text(
                        'Ride Status: $_rideStatus',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _bookRide,
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Book Ride',
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}

extension on ApiService {
  post(String s, Map<String, double> map) {}
}
