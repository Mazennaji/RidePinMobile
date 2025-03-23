import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = 'https://your-api-url.com';

  Future<void> processPayment(String userId, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/process'),
      body: json.encode({'userId': userId, 'amount': amount}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to process payment');
    }
  }
}
