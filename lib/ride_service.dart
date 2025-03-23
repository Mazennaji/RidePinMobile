import 'dart:convert';
import 'package:http/http.dart' as http;

class RideService {
  final String baseUrl = 'https://your-api-url.com';

  Future<List<dynamic>> fetchAvailableRides() async {
    final response = await http.get(Uri.parse('$baseUrl/rides'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rides');
    }
  }

  Future<void> bookRide(String rideId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/book'),
      body: json.encode({'userId': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book ride');
    }
  }
}
