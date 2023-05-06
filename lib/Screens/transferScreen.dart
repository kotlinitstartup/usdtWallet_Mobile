import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/AppMenu.dart';
import '../api/api_service.dart';
import '../auth.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _responseMessage = '';

  Future<void> _submitTransferRequest() async {
    final accessToken = await getAccessToken();
    final url = Uri.parse(ApiService.baseUrl + '/wallet/transfer');
    final body = {
      'id': _idController.text,
      'amount': _amountController.text,
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': '$accessToken',
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    setState(() {
      _responseMessage = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer USDT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Recipient ID',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount of USDT to transfer',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitTransferRequest,
              child: Text('Transfer'),
            ),

            SizedBox(height: 16.0),
            Text(_responseMessage),
          ],
        ),
      ),
      drawer: AppMenu(),
    );
  }
}
