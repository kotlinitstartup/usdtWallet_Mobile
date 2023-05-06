import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/AppMenu.dart';
import '../auth.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';

class Transaction {

  final int id;
  var senderId;
  var receiverId;
  final String amount;
  final DateTime timestamp;
  final String status;
  final String type;

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.type,
  });
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final accessToken = await getAccessToken();
    final url = Uri.parse(ApiService.baseUrl + '/wallet/history');
    final headers = {
      'Authorization': '$accessToken',
    };
    final response = await http.get(url, headers: headers);
    final responseData = await json.decode(response.body);

    setState(() {
      _transactions = responseData.map<Transaction>((transactionData) {
        final id = transactionData['id'] ?? '';
        final senderUsername = transactionData['sender_id'] ?? '';
        final receiverUsername = transactionData['receiver_id'] ?? '';
        final amount = transactionData['amount'] ?? '';
        final timestamp = DateTime.parse(transactionData['timestamp_'] ?? '');
        final status = transactionData['status'] ?? '';
        final type = transactionData['type_'] ?? '';
        return Transaction(
          id: id,
          senderId: senderUsername,
          receiverId: receiverUsername,
          amount: amount,
          timestamp: timestamp,
          status: status,
          type: type,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  final transaction = _transactions[index];
                  final date = DateFormat.yMd().add_Hms().format(transaction.timestamp);

                  final sender = transaction.senderId != null ? 'From: ${transaction.senderId}' : '';
                  final receiver = transaction.receiverId != null ? 'To: ${transaction.receiverId}' : '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction ID: ${transaction.id}'),
                      Text('$sender'),
                      Text('$receiver'),
                      Text('Amount: \$${transaction.amount}'),
                      Text('Timestamp: $date'),
                      Text('Status: ${transaction.status}'),
                      Text('Type: ${transaction.type}'),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: AppMenu(),
    );
  }
}
