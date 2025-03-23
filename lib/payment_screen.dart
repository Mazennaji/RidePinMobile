import 'package:flutter/material.dart';
import 'payment_service.dart'; // Import the PaymentService

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentService = PaymentService();
      await paymentService.processPayment('user123', 50.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment processed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child:
            _isProcessing
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _processPayment,
                  child: Text('Process Payment'),
                ),
      ),
    );
  }
}
