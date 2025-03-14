import 'package:flutter/material.dart';
import 'api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await ApiService.dio.get('/transactions');
      setState(() {
        transactions = response.data;
      });
    } catch (e) {
      print('Failed to fetch transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text('Amount: \$${transaction['amount']}'),
            subtitle: Text('Status: ${transaction['status']}'),
          );
        },
      ),
    );
  }
}
